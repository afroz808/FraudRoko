import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumConfig {
  final double monthlyPrice;
  final double yearlyPrice;
  final bool monthlyEnabled;
  final bool yearlyEnabled;

  final bool offerEnabled;
  final bool monthlyOfferEnabled;
  final bool yearlyOfferEnabled;
  final String offerTitle;
  final double? monthlyOfferPrice;
  final double? yearlyOfferPrice;

  final DateTime? offerStart;
  final DateTime? offerEnd;

  const PremiumConfig({
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.monthlyEnabled,
    required this.yearlyEnabled,
    required this.offerEnabled,
    required this.monthlyOfferEnabled,
    required this.yearlyOfferEnabled,
    required this.offerTitle,
    required this.monthlyOfferPrice,
    required this.yearlyOfferPrice,
    required this.offerStart,
    required this.offerEnd,
  });

  factory PremiumConfig.fromFirestore(Map<String, dynamic> data) {
    DateTime? timestampToDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    final legacyOffer = (data['offerPrice'] as num?)?.toDouble();

    final monthlyOffer =
        (data['monthlyOfferPrice'] as num?)?.toDouble() ?? legacyOffer;

    final yearlyOffer =
        (data['yearlyOfferPrice'] as num?)?.toDouble() ?? legacyOffer;

    final legacyEnabled = data['offerEnabled'] as bool? ?? false;

    return PremiumConfig(
      monthlyPrice: (data['monthlyPrice'] as num?)?.toDouble() ?? 99,
      yearlyPrice: (data['yearlyPrice'] as num?)?.toDouble() ?? 999,
      monthlyEnabled: data['monthlyEnabled'] as bool? ?? true,
      yearlyEnabled: data['yearlyEnabled'] as bool? ?? true,
      offerEnabled:
          legacyEnabled ||
          (data['monthlyOfferEnabled'] as bool? ?? false) ||
          (data['yearlyOfferEnabled'] as bool? ?? false),
      monthlyOfferEnabled:
          data['monthlyOfferEnabled'] as bool? ?? legacyEnabled,
      yearlyOfferEnabled: data['yearlyOfferEnabled'] as bool? ?? legacyEnabled,
      offerTitle: data['offerTitle'] as String? ?? '',
      monthlyOfferPrice: monthlyOffer,
      yearlyOfferPrice: yearlyOffer,
      offerStart: timestampToDate(data['offerStart']),
      offerEnd: timestampToDate(data['offerEnd']),
    );
  }

  bool isOfferActiveFor(String plan) {
    final enabled = plan == 'yearly' ? yearlyOfferEnabled : monthlyOfferEnabled;

    final price = plan == 'yearly' ? yearlyOfferPrice : monthlyOfferPrice;

    if (!offerEnabled || !enabled || price == null) {
      return false;
    }

    final now = DateTime.now();

    if (offerStart != null && now.isBefore(offerStart!)) {
      return false;
    }

    if (offerEnd != null && !now.isBefore(offerEnd!)) {
      return false;
    }

    return true;
  }

  double priceFor(String plan) {
    final normalPrice = plan == 'yearly' ? yearlyPrice : monthlyPrice;

    if (isOfferActiveFor(plan)) {
      final offerPrice = plan == 'yearly'
          ? yearlyOfferPrice
          : monthlyOfferPrice;

      if (offerPrice != null) {
        return offerPrice;
      }
    }

    return normalPrice;
  }
}

class PremiumConfigService {
  PremiumConfigService._();

  static final PremiumConfigService instance = PremiumConfigService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<PremiumConfig> watchConfig() {
    return _firestore
        .collection('premium_config')
        .doc('plans')
        .snapshots()
        .map(
          (snapshot) =>
              PremiumConfig.fromFirestore(snapshot.data() ?? const {}),
        );
  }

  Future<PremiumConfig> getConfig() async {
    final snapshot = await _firestore
        .collection('premium_config')
        .doc('plans')
        .get();

    return PremiumConfig.fromFirestore(snapshot.data() ?? const {});
  }
}
