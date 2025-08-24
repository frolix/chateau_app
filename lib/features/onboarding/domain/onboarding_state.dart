import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState extends ChangeNotifier {
  static const _key = 'onboarding_complete';

  bool _seen = false;
  bool get seen => _seen;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _seen = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> complete() async {
    if (_seen) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _seen = true;
    notifyListeners();
  }
}
