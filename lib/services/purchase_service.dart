import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/product_ids.dart';
import '../models/subscription_tier.dart';
import 'premium_service.dart';

/// Service to handle in-app purchases
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final PremiumService _premiumService = PremiumService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;

  /// Initialize the purchase service
  Future<void> init() async {
    // Check if in-app purchase is available
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
      return;
    }

    // Set up purchase listener
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();
  }

  /// Load available products from the store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        ProductIds.allProductIds.toSet(),
      );

      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('Exception loading products: $e');
    }
  }

  /// Get product details by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      debugPrint('Product not found: $productId');
      return false;
    }

    _purchasePending = true;

    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      // Determine if it's a subscription or consumable
      if (ProductIds.subscriptions.contains(productId)) {
        return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _iap.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('Error purchasing product: $e');
      _purchasePending = false;
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  /// Handle individual purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _purchasePending = true;
      return;
    }

    if (purchaseDetails.status == PurchaseStatus.error) {
      _purchasePending = false;
      debugPrint('Purchase error: ${purchaseDetails.error}');
      return;
    }

    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // Verify purchase (in production, verify with your backend)
      final valid = await _verifyPurchase(purchaseDetails);

      if (valid) {
        await _deliverProduct(purchaseDetails);
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }

      _purchasePending = false;
    }

    if (purchaseDetails.status == PurchaseStatus.canceled) {
      _purchasePending = false;
      debugPrint('Purchase canceled');
    }
  }

  /// Verify purchase (placeholder - implement server-side verification in production)
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In production, send the receipt to your backend for verification
    // For now, we'll just return true
    debugPrint('Verifying purchase: ${purchaseDetails.productID}');
    return true;
  }

  /// Deliver the purchased product
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;

    // Handle subscriptions
    if (productId == ProductIds.premiumMonthly) {
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await _premiumService.upgradeToPremium(
          SubscriptionTier.premiumMonthly, expiryDate);
      debugPrint('Delivered premium monthly subscription');
    } else if (productId == ProductIds.premiumAnnual) {
      final expiryDate = DateTime.now().add(const Duration(days: 365));
      await _premiumService.upgradeToPremium(
          SubscriptionTier.premiumAnnual, expiryDate);
      debugPrint('Delivered premium annual subscription');
    }

    // Handle consumables (donations)
    else if (ProductIds.consumables.contains(productId)) {
      debugPrint('Delivered donation: $productId');
      // Donations don't unlock features, just show thank you message
    }

    // Handle non-consumables
    else if (ProductIds.nonConsumables.contains(productId)) {
      debugPrint('Delivered non-consumable: $productId');
      // Handle one-time purchases like extra protectors or theme packs
    }
  }

  /// Dispose of the service
  void dispose() {
    _subscription?.cancel();
  }
}
