import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class GooglePlayBillingService {
  GooglePlayBillingService._();

  static final GooglePlayBillingService instance = GooglePlayBillingService._();

  static const String monthlyProductId = 'fraudroko_premium_monthly';
  static const String yearlyProductId = 'fraudroko_premium_yearly';

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _available = false;

  bool get isAvailable => _available;

  Future<void> initialize({
    required void Function(PurchaseDetails purchase) onPurchase,
  }) async {
    _available = await _iap.isAvailable();

    if (!_available) {
      debugPrint('Google Play Billing is not available.');
      return;
    }

    _purchaseSubscription ??= _iap.purchaseStream.listen(
      (purchases) {
        for (final purchase in purchases) {
          onPurchase(purchase);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Google Play Billing error: $error');
      },
    );
  }

  Future<List<ProductDetails>> loadProducts() async {
    if (!_available) {
      return const [];
    }

    const productIds = <String>{monthlyProductId, yearlyProductId};

    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
      return const [];
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    return response.productDetails;
  }

  Future<bool> purchase(ProductDetails product) async {
    if (!_available) {
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}
