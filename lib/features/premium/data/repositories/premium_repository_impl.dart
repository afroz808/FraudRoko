import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  const PremiumRepositoryImpl();

  @override
  Future<PremiumStatus> getPremiumStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return PremiumStatus.free;

    final snapshot = await FirebaseFirestore.instance
        .collection('premium_entitlements')
        .doc(uid)
        .get();

    final data = snapshot.data();
    if (data == null) return PremiumStatus.free;

    final status = data['status'];
    final expiresAt = data['expiresAt'];

    if (status != 'active') return PremiumStatus.free;

    DateTime? expiry;
    if (expiresAt is Timestamp) {
      expiry = expiresAt.toDate();
    } else if (expiresAt is String) {
      expiry = DateTime.tryParse(expiresAt);
    }

    // Never grant Premium when the backend entitlement has no valid expiry.
    if (expiry == null || !expiry.isAfter(DateTime.now())) {
      return PremiumStatus.free;
    }

    return PremiumStatus.premium;
  }
}
