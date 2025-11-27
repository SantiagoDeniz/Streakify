import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  bool _reduceMotion = false;
  double _textScaleFactor = 1.0;
  bool _screenReaderEnabled = false;
  bool _colorblindMode = false;
  bool _increasedTouchTargets = false;

  bool get reduceMotion => _reduceMotion;
  double get textScaleFactor => _textScaleFactor;
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get colorblindMode => _colorblindMode;
  bool get increasedTouchTargets => _increasedTouchTargets;

  // Minimum touch target size in logical pixels (44x44pt recommended by both Apple and Google)
  static const double minTouchTargetSize = 44.0;
  static const double increasedTouchTargetSize = 56.0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    _colorblindMode = prefs.getBool('colorblindMode') ?? false;
    _increasedTouchTargets = prefs.getBool('increasedTouchTargets') ?? false;
    
    // Check system accessibility settings if possible, otherwise default to false
    // In a real app we might use MediaQuery.of(context).accessibleNavigation
    // but this service is initialized before UI.
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double value) async {
    _textScaleFactor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScaleFactor', value);
    notifyListeners();
  }

  Future<void> setColorblindMode(bool value) async {
    _colorblindMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('colorblindMode', value);
    notifyListeners();
  }

  Future<void> setIncreasedTouchTargets(bool value) async {
    _increasedTouchTargets = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('increasedTouchTargets', value);
    notifyListeners();
  }

  /// Update accessibility settings from system MediaQuery
  void updateFromMediaQuery(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    // Update reduce motion from system settings
    if (mediaQuery.disableAnimations && !_reduceMotion) {
      _reduceMotion = true;
      notifyListeners();
    }
    
    // Note: We don't automatically disable reduce motion if system has it off,
    // because user might have enabled it manually in our app
  }
  
  /// Get the appropriate touch target size based on settings
  double getTouchTargetSize() {
    return _increasedTouchTargets ? increasedTouchTargetSize : minTouchTargetSize;
  }

  /// Helper to ensure a widget meets minimum touch target size
  Widget ensureTouchTarget({
    required Widget child,
    double? customSize,
  }) {
    final size = customSize ?? getTouchTargetSize();
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      child: child,
    );
  }
  
  /// Helper to wrap widgets that should respect motion reduction
  Widget reduceMotionWrapper({
    required Widget child, 
    required Widget Function(BuildContext, Widget) transitionBuilder
  }) {
    if (_reduceMotion) {
      return child;
    }
    return Builder(builder: (context) => transitionBuilder(context, child));
  }

  /// Check if high contrast is needed (from system or theme)
  bool isHighContrastNeeded(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast;
  }
}
