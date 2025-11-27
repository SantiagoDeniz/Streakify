import 'premium_feature.dart';

/// Subscription tier levels
enum SubscriptionTier {
  free,
  premiumMonthly,
  premiumAnnual,
}

/// Extension for subscription tier details
extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gratis';
      case SubscriptionTier.premiumMonthly:
        return 'Premium Mensual';
      case SubscriptionTier.premiumAnnual:
        return 'Premium Anual';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return 'Funcionalidades básicas';
      case SubscriptionTier.premiumMonthly:
        return 'Todas las características premium';
      case SubscriptionTier.premiumAnnual:
        return 'Todas las características premium con descuento';
    }
  }

  /// Suggested price in USD (actual prices configured in stores)
  String get suggestedPrice {
    switch (this) {
      case SubscriptionTier.free:
        return '\$0';
      case SubscriptionTier.premiumMonthly:
        return '\$2.99/mes';
      case SubscriptionTier.premiumAnnual:
        return '\$24.99/año';
    }
  }

  /// Features included in this tier
  List<PremiumFeature> get includedFeatures {
    switch (this) {
      case SubscriptionTier.free:
        return []; // No premium features
      case SubscriptionTier.premiumMonthly:
      case SubscriptionTier.premiumAnnual:
        return PremiumFeature.values; // All premium features
    }
  }

  /// Activity limit for this tier
  int? get activityLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.premiumMonthly:
      case SubscriptionTier.premiumAnnual:
        return null; // Unlimited
    }
  }

  bool get isPremium {
    return this != SubscriptionTier.free;
  }
}
