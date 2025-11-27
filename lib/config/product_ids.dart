/// Product IDs for in-app purchases
/// These must match the IDs configured in Google Play Console and App Store Connect
class ProductIds {
  // Subscriptions
  static const String premiumMonthly = 'streakify_premium_monthly';
  static const String premiumAnnual = 'streakify_premium_annual';
  
  // Donations (one-time purchases)
  static const String donation1 = 'streakify_donation_1';
  static const String donation3 = 'streakify_donation_3';
  static const String donation5 = 'streakify_donation_5';
  static const String donation10 = 'streakify_donation_10';
  
  // Optional one-time purchases
  static const String extraProtectors = 'streakify_protectors_pack';
  static const String premiumThemes = 'streakify_themes_pack';
  
  /// All subscription product IDs
  static const List<String> subscriptions = [
    premiumMonthly,
    premiumAnnual,
  ];
  
  /// All consumable product IDs (donations)
  static const List<String> consumables = [
    donation1,
    donation3,
    donation5,
    donation10,
  ];
  
  /// All non-consumable product IDs
  static const List<String> nonConsumables = [
    extraProtectors,
    premiumThemes,
  ];
  
  /// All product IDs
  static List<String> get allProductIds => [
    ...subscriptions,
    ...consumables,
    ...nonConsumables,
  ];
}
