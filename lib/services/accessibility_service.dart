import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  bool _reduceMotion = false;
  double _textScaleFactor = 1.0;
  bool _screenReaderEnabled = false;

  bool get reduceMotion => _reduceMotion;
  double get textScaleFactor => _textScaleFactor;
  bool get screenReaderEnabled => _screenReaderEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    
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
  
  // Helper to wrap widgets that should respect motion reduction
  Widget reduceMotionWrapper({
    required Widget child, 
    required Widget Function(BuildContext, Widget) transitionBuilder
  }) {
    if (_reduceMotion) {
      return child;
    }
    return Builder(builder: (context) => transitionBuilder(context, child));
  }
}
