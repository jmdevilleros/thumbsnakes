import 'package:flutter_test/flutter_test.dart';
import 'package:thumbsnakes/managers/score_manager.dart';
import 'package:thumbsnakes/utils/app_strings.dart';

void main() {
  test('clock ignores paused time and resets', () {
    final s = ScoreManager();
    s.advance(1.5, running: true);
    s.advance(10, running: false);
    s.advance(0.25, running: true);
    expect(s.elapsed, closeTo(1.75, 1e-9));
    expect(AppStrings.seconds(s.elapsed), '1.8s');
    s.reset();
    expect(s.elapsed, 0);
  });
}
