import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyCurrentWeight = 'current_weight';
  static const String _keyGoalWeight = 'goal_weight';
  static const String _keyIsKg = 'is_kg';
  static const String _keyHistory = 'weight_history';
  static const String _keyLanguage = 'language_code';
  static const String _keyTheme = 'theme_mode';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // Current Weight
  Future<void> saveCurrentWeight(double weight) => _prefs.setDouble(_keyCurrentWeight, weight);
  double? getCurrentWeight() => _prefs.getDouble(_keyCurrentWeight);

  // Goal Weight
  Future<void> saveGoalWeight(double weight) => _prefs.setDouble(_keyGoalWeight, weight);
  double? getGoalWeight() => _prefs.getDouble(_keyGoalWeight);

  // Unit Preference
  Future<void> saveIsKg(bool isKg) => _prefs.setBool(_keyIsKg, isKg);
  bool getIsKg() => _prefs.getBool(_keyIsKg) ?? true; // Default to Kg

  // Language Preference
  Future<void> saveLanguage(String code) => _prefs.setString(_keyLanguage, code);
  String? getLanguage() => _prefs.getString(_keyLanguage);

  // Theme Preference
  Future<void> saveTheme(String theme) => _prefs.setString(_keyTheme, theme);
  String getTheme() => _prefs.getString(_keyTheme) ?? 'system';

  // History
  Future<void> addHistoryEntry(double weight, DateTime date) async {
    List<String> history = _prefs.getStringList(_keyHistory) ?? [];
    Map<String, dynamic> entry = {
      'weight': weight,
      'date': date.toIso8601String(),
    };
    history.add(jsonEncode(entry));
    await _prefs.setStringList(_keyHistory, history);
  }

  List<Map<String, dynamic>> getHistory() {
    List<String> history = _prefs.getStringList(_keyHistory) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
  
  Future<void> clearHistory() async {
    await _prefs.remove(_keyHistory);
  }
}
