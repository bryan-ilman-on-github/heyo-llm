import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ThemePreference { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemePreference _preference = ThemePreference.system;

  ThemePreference get preference => _preference;

  ThemeMode get themeMode {
    switch (_preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    if (_preference == ThemePreference.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _preference == ThemePreference.dark;
  }

  void setThemePreference(ThemePreference preference) {
    _preference = preference;
    notifyListeners();
  }

  void toggleTheme() {
    if (_preference == ThemePreference.dark) {
      _preference = ThemePreference.light;
    } else {
      _preference = ThemePreference.dark;
    }
    notifyListeners();
  }

  void setLight() {
    _preference = ThemePreference.light;
    notifyListeners();
  }

  void setDark() {
    _preference = ThemePreference.dark;
    notifyListeners();
  }

  void setSystem() {
    _preference = ThemePreference.system;
    notifyListeners();
  }
}
