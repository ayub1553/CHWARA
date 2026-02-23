import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class StorageService {
  static const String _historyKey = 'game_history_final';
  static const String _statsKey = 'player_stats_final';

  static Future<void> saveMatch(String result, int size) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    String date = DateFormat('MM/dd HH:mm').format(DateTime.now());
    history.insert(0, "[$date] $result ($size x $size)");
    await prefs.setStringList(_historyKey, history.take(20).toList());
  }

  static Future<void> updateStats(String name, bool isWin, int points) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> stats = jsonDecode(prefs.getString(_statsKey) ?? "{}");
    if (!stats.containsKey(name)) stats[name] = {'wins': 0, 'points': 0};
    if (isWin) stats[name]['wins'] = (stats[name]['wins'] ?? 0) + 1;
    stats[name]['points'] = (stats[name]['points'] ?? 0) + points;
    await prefs.setString(_statsKey, jsonEncode(stats));
  }

  static Future<Map<String, dynamic>> getData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'history': prefs.getStringList(_historyKey) ?? [],
      'stats': jsonDecode(prefs.getString(_statsKey) ?? "{}"),
    };
  }

  static Future<void> resetHistory() async =>
      (await SharedPreferences.getInstance()).remove(_historyKey);
  static Future<void> resetStats() async =>
      (await SharedPreferences.getInstance()).remove(_statsKey);
}

