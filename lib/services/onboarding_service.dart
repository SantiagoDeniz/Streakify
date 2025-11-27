import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding and tutorial state
class OnboardingService extends ChangeNotifier {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  bool _isFirstLaunch = true;
  bool _hasCompletedOnboarding = false;
  bool _hasCompletedTutorial = false;
  Set<String> _shownTooltips = {};
  String? _lastSeenVersion;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasCompletedTutorial => _hasCompletedTutorial;
  Set<String> get shownTooltips => _shownTooltips;
  String? get lastSeenVersion => _lastSeenVersion;

  /// Initialize onboarding service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    _hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
    _hasCompletedTutorial = prefs.getBool('has_completed_tutorial') ?? false;
    _shownTooltips = prefs.getStringList('shown_tooltips')?.toSet() ?? {};
    _lastSeenVersion = prefs.getString('last_seen_version');
    
    notifyListeners();
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    
    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    
    await completeFirstLaunch();
    notifyListeners();
  }

  /// Mark tutorial as complete
  Future<void> completeTutorial() async {
    _hasCompletedTutorial = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_tutorial', true);
    
    notifyListeners();
  }

  /// Mark a tooltip as shown
  Future<void> markTooltipShown(String tooltipId) async {
    _shownTooltips.add(tooltipId);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('shown_tooltips', _shownTooltips.toList());
    
    notifyListeners();
  }

  /// Check if a tooltip has been shown
  bool hasShownTooltip(String tooltipId) {
    return _shownTooltips.contains(tooltipId);
  }

  /// Update last seen version
  Future<void> updateLastSeenVersion(String version) async {
    _lastSeenVersion = version;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_seen_version', version);
    
    notifyListeners();
  }

  /// Check if there's a new version (for changelog)
  bool hasNewVersion(String currentVersion) {
    if (_lastSeenVersion == null) return true;
    return _lastSeenVersion != currentVersion;
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    _isFirstLaunch = true;
    _hasCompletedOnboarding = false;
    _hasCompletedTutorial = false;
    _shownTooltips.clear();
    _lastSeenVersion = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_first_launch');
    await prefs.remove('has_completed_onboarding');
    await prefs.remove('has_completed_tutorial');
    await prefs.remove('shown_tooltips');
    await prefs.remove('last_seen_version');
    
    notifyListeners();
  }

  /// Reset tutorial only
  Future<void> resetTutorial() async {
    _hasCompletedTutorial = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_tutorial', false);
    
    notifyListeners();
  }
}
