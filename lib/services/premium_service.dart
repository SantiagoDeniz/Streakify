import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/premium_feature.dart';
import '../models/subscription_tier.dart';

/// Service to manage premium status and feature gating
class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  SubscriptionTier _currentTier = SubscriptionTier.free;
  DateTime? _subscriptionExpiryDate;
  bool _isLifetime = false;

  SubscriptionTier get currentTier => _currentTier;
  bool get isPremium => _currentTier.isPremium || _isLifetime;
  bool get isLifetime => _isLifetime;
  DateTime? get subscriptionExpiryDate => _subscriptionExpiryDate;

  /// Initialize premium service and load saved state
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load subscription tier
    final tierIndex = prefs.getInt('subscription_tier') ?? 0;
    _currentTier = SubscriptionTier.values[tierIndex];
    
    // Load expiry date
    final expiryTimestamp = prefs.getInt('subscription_expiry');
    if (expiryTimestamp != null) {
      _subscriptionExpiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      
      // Check if subscription has expired
      if (_subscriptionExpiryDate!.isBefore(DateTime.now())) {
        await _downgradeToFree();
      }
    }
    
    // Load lifetime status
    _isLifetime = prefs.getBool('is_lifetime') ?? false;
    
    notifyListeners();
  }

  /// Check if user has access to a specific premium feature
  bool hasFeature(PremiumFeature feature) {
    if (_isLifetime) return true;
    return _currentTier.includedFeatures.contains(feature);
  }

  /// Check if user can create more activities
  bool canCreateActivity(int currentActivityCount) {
    if (isPremium) return true;
    
    final limit = _currentTier.activityLimit;
    if (limit == null) return true;
    
    return currentActivityCount < limit;
  }

  /// Get remaining activities for free tier
  int getRemainingActivities(int currentActivityCount) {
    if (isPremium) return -1; // Unlimited
    
    final limit = _currentTier.activityLimit ?? 0;
    return (limit - currentActivityCount).clamp(0, limit);
  }

  /// Upgrade to premium tier
  Future<void> upgradeToPremium(SubscriptionTier tier, DateTime expiryDate) async {
    _currentTier = tier;
    _subscriptionExpiryDate = expiryDate;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscription_tier', tier.index);
    await prefs.setInt('subscription_expiry', expiryDate.millisecondsSinceEpoch);
    
    notifyListeners();
  }

  /// Set lifetime premium status
  Future<void> setLifetime(bool value) async {
    _isLifetime = value;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_lifetime', value);
    
    notifyListeners();
  }

  /// Downgrade to free tier
  Future<void> _downgradeToFree() async {
    _currentTier = SubscriptionTier.free;
    _subscriptionExpiryDate = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscription_tier', 0);
    await prefs.remove('subscription_expiry');
    
    notifyListeners();
  }

  /// Restore premium status (called after successful purchase restoration)
  Future<void> restorePremium(SubscriptionTier tier, DateTime expiryDate) async {
    await upgradeToPremium(tier, expiryDate);
  }

  /// Check if subscription needs renewal soon (within 7 days)
  bool needsRenewalSoon() {
    if (_isLifetime || !isPremium) return false;
    if (_subscriptionExpiryDate == null) return false;
    
    final daysUntilExpiry = _subscriptionExpiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  /// Get days until subscription expires
  int? getDaysUntilExpiry() {
    if (_isLifetime || _subscriptionExpiryDate == null) return null;
    return _subscriptionExpiryDate!.difference(DateTime.now()).inDays;
  }

  /// Clear all premium data (for testing)
  Future<void> clearPremiumData() async {
    _currentTier = SubscriptionTier.free;
    _subscriptionExpiryDate = null;
    _isLifetime = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('subscription_tier');
    await prefs.remove('subscription_expiry');
    await prefs.remove('is_lifetime');
    
    notifyListeners();
  }
}
