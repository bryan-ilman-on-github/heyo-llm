import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _branchColoringKey = 'branch_coloring_enabled';

  bool _branchColoringEnabled = false;
  SharedPreferences? _prefs;

  bool get branchColoringEnabled => _branchColoringEnabled;

  /// Initialize with persisted settings
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _branchColoringEnabled = _prefs?.getBool(_branchColoringKey) ?? false;
    notifyListeners();
  }

  void toggleBranchColoring() {
    _branchColoringEnabled = !_branchColoringEnabled;
    _prefs?.setBool(_branchColoringKey, _branchColoringEnabled);
    notifyListeners();
  }

  void setBranchColoring(bool enabled) {
    _branchColoringEnabled = enabled;
    _prefs?.setBool(_branchColoringKey, _branchColoringEnabled);
    notifyListeners();
  }
}
