import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thumbsnakes/managers/high_score_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to 0 and saves only when better', () async {
    SharedPreferences.setMockInitialValues({});
    final s = HighScoreStore();
    expect(await s.load(), 0);
    expect(await s.saveIfBetter(12.5), isTrue);
    expect(await s.saveIfBetter(10), isFalse);
    final reloaded = HighScoreStore();
    expect(await reloaded.load(), 12.5);
  });

  test('loads persisted value', () async {
    SharedPreferences.setMockInitialValues({HighScoreStore.key: 33.3});
    expect(await HighScoreStore().load(), 33.3);
  });
}
