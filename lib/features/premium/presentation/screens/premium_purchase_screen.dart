import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../providers/premium_provider.dart';
import '../../data/services/google_play_billing_service.dart';
import '../../../../core/localization/app_text.dart';

class PremiumPurchaseScreen extends StatefulWidget {
  final String initialPlan;

  const PremiumPurchaseScreen({
    super.key,
    this.initialPlan = 'monthly',
  });

  @override
  State<PremiumPurchaseScreen> createState() => _PremiumPurchaseScreenState();
}

class _PremiumPurchaseScreenState extends State<PremiumPurchaseScreen> {
  final _billing = GooglePlayBillingService.instance;
  List<ProductDetails> _products = const [];
  bool _loading = true;
  bool _purchaseInProgress = false;
  String? _error;
  late String _selectedPlan;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.initialPlan == 'yearly' ? 'yearly' : 'monthly';
    _initialize();
  }

  Future<void> _initialize() async {
    await _billing.initialize(onPurchase: _handlePurchase);
    final products = await _billing.loadProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
      if (products.isEmpty && !_billing.isAvailable) {
        _error = AppText.t(context, 'Google Play Billing is not available on this device.');
      }
    });
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      if (mounted) setState(() => _purchaseInProgress = true);
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      if (mounted) {
        setState(() {
          _purchaseInProgress = false;
          _error = AppText.t(context, 'Purchase failed.');
        });
      }
      return;
    }

    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _purchaseInProgress = false;
          _error = AppText.t(context, 'Please login and try again.');
        });
      }
      return;
    }

    try {
      final purchaseToken = purchase.verificationData.serverVerificationData.trim();
      if (purchaseToken.isEmpty) {
        throw StateError('Google Play purchase token is missing.');
      }

      // Premium is granted only after the backend verifies the purchase token
      // directly with Google Play. Never use a local flag as proof of payment.
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.trim().isEmpty) {
        throw StateError('Firebase authentication token is missing.');
      }

      final client = HttpClient();
      try {
        final request = await client.postUrl(
          Uri.parse(
            'https://fraudroko-play-verify.fraudroko-link-check.workers.dev/verify',
          ),
        );
        request.headers.contentType = ContentType.json;
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
        request.add(utf8.encode(jsonEncode(<String, dynamic>{
          'purchaseToken': purchaseToken,
          'productId': purchase.productID,
        })));

        final response = await request.close().timeout(
          const Duration(seconds: 15),
        );
        final body = await utf8.decoder.bind(response).join();

        Map<String, dynamic> data;
        try {
          data = Map<String, dynamic>.from(jsonDecode(body) as Map);
        } catch (_) {
          throw StateError('Invalid verification response from backend.');
        }

        if (response.statusCode != 200) {
          throw StateError(
            data['error']?.toString() ?? 'Purchase verification failed.',
          );
        }

        final verified = data['verified'] == true;
        final premium = data['premium'] == true;
        if (!verified || !premium) {
          throw StateError('Google Play purchase was not verified as active.');
        }
      } finally {
        client.close(force: true);
      }

      // The backend acknowledges the verified subscription. Completing the
      // Flutter purchase here closes the client transaction state as well.
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      if (!mounted) return;
      await context.read<PremiumProvider>().loadStatus();
      if (!mounted) return;
      setState(() => _purchaseInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.t(context, 'Premium activated successfully.'))),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _purchaseInProgress = false;
          _error = AppText.t(
            context,
            'Payment was received but could not be verified yet. Please try Restore purchases after verification is available.',
          );
        });
      }
    }
  }

  Future<void> _buy(ProductDetails product) async {
    if (_purchaseInProgress) return;

    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        setState(() {
          _error = AppText.t(context, 'Please login before purchasing Premium.');
        });
      }
      return;
    }
    setState(() {
      _purchaseInProgress = true;
      _error = null;
    });
    final started = await _billing.purchase(product);
    if (!started && mounted) {
      setState(() {
        _purchaseInProgress = false;
        _error = AppText.t(context, 'Google Play could not start the purchase.');
      });
    }
  }


  Future<void> _restorePurchases() async {
    if (_purchaseInProgress) return;

    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        setState(() {
          _error = AppText.t(context, 'Please login before restoring Premium.');
        });
      }
      return;
    }

    setState(() {
      _purchaseInProgress = true;
      _error = null;
    });

    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppText.t(context, 'Could not restore purchases. Please try again.');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _purchaseInProgress = false);
      }
    }
  }
  ProductDetails? _find(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final monthly = _find(GooglePlayBillingService.monthlyProductId);
    final yearly = _find(GooglePlayBillingService.yearlyProductId);

    return Scaffold(
      appBar: AppBar(title: Text(AppText.t(context, 'FraudRoko Premium'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(Icons.workspace_premium_rounded, size: 64),
                const SizedBox(height: 12),
                Text(
                  AppText.t(context, 'Keep your phone security protected'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  AppText.t(context, 'Unlimited Phone Security Scans and detailed Security Reports.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 24),
                _benefit(context, 'Unlimited Phone Security Scans'),
                _benefit(context, 'Detailed Security Reports'),
                _benefit(context, 'Hidden App Detection'),
                _benefit(context, 'Background Security Monitoring'),
                _benefit(context, 'Risk & Threat Notifications'),
                const SizedBox(height: 24),
                if (monthly != null)
                  _planCard(
                    context,
                    monthly,
                    'Monthly',
                    monthly.price,
                    GooglePlayBillingService.monthlyProductId,
                  ),
                if (yearly != null)
                  _planCard(
                    context,
                    yearly,
                    'Yearly',
                    yearly.price,
                    GooglePlayBillingService.yearlyProductId,
                  ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _purchaseInProgress ? null : _restorePurchases,
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(AppText.t(context, 'Restore purchases')),
                ),
                if (_products.isEmpty)
                  Text(
                    AppText.t(context, 'Premium products are not available yet. Please try again when Google Play products are configured.'),
                    textAlign: TextAlign.center,
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                ],
              ],
            ),
    );
  }

  Widget _benefit(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 21),
          const SizedBox(width: 10),
          Expanded(child: Text(AppText.t(context, text))),
        ],
      ),
    );
  }

  Widget _planCard(
    BuildContext context,
    ProductDetails product,
    String title,
    String price,
    String productId,
  ) {
    final selected = (_selectedPlan == 'yearly' &&
            productId == GooglePlayBillingService.yearlyProductId) ||
        (_selectedPlan != 'yearly' &&
            productId == GooglePlayBillingService.monthlyProductId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: _purchaseInProgress
            ? null
            : () => setState(() => _selectedPlan =
                productId == GooglePlayBillingService.yearlyProductId
                    ? 'yearly'
                    : 'monthly'),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
        title: Text(AppText.t(context, title), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: _purchaseInProgress ? null : () => _buy(product),
          child: Text(AppText.t(context, 'BUY NOW')),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_billing.dispose());
    super.dispose();
  }
}
