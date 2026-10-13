/// Centralized UI strings (v1: English only, i18n-ready).
class AppStrings {
  AppStrings._();

  static const String title = 'THUMBSNAKES';
  static const String appName = 'Thumbsnakes';
  static const String play = 'PLAY';
  static const String resume = 'RESUME';
  static const String menu = 'MENU';
  static const String retry = 'RETRY';
  static const String paused = 'PAUSED';
  static const String gameOver = 'GAME OVER';
  static const String newBest = 'NEW BEST';
  static const String time = 'TIME';
  static const String highScore = 'BEST';
  static const String controlsHint =
      'Left thumb: left snake · Right thumb: right snake';

  /// Formats survived seconds with one decimal, e.g. `42.3s` (RF-007).
  static String seconds(double value) => '${value.toStringAsFixed(1)}s';
}
