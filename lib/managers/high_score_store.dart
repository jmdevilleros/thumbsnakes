import 'package:shared_preferences/shared_preferences.dart';

/// Persistent best time (RF-007). Fail-soft: errors keep the value in memory.
class HighScoreStore {
  static const String key = 'high_score';
  double _best = 0;
  double get best => _best;

  Future<double> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _best = prefs.getDouble(key) ?? 0;
    } catch (_) {
      // keep in-memory value
    }
    return _best;
  }

  /// Returns true when [score] is a new best.
  Future<bool> saveIfBetter(double score) async {
    if (score <= _best) return false;
    _best = score;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, score);
    } catch (_) {
      // fail-soft
    }
    return true;
  }
}
