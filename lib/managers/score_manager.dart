/// Survival clock (RF-007): only advances while the run is active.
class ScoreManager {
  double _elapsed = 0;
  double get elapsed => _elapsed;

  void advance(double dt, {required bool running}) {
    if (running && dt > 0) _elapsed += dt;
  }

  void reset() => _elapsed = 0;
}
