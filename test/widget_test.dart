import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thumbsnakes/main.dart';
import 'package:thumbsnakes/utils/app_strings.dart';

void main() {
  testWidgets('menu shows PLAY, best and hint', (tester) async {
    SharedPreferences.setMockInitialValues({'high_score': 7.25});
    await tester.pumpWidget(ThumbsnakesApp());
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.play), findsOneWidget);
    expect(find.text('${AppStrings.highScore} 7.3s'), findsOneWidget);
    expect(find.text(AppStrings.controlsHint), findsOneWidget);
  });

  testWidgets('PLAY → game → pause → MENU', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ThumbsnakesApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.play));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('pauseButton')), findsOneWidget);
    await tester.tap(find.byKey(const Key('pauseButton')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppStrings.resume), findsOneWidget);
    await tester.tap(find.text(AppStrings.menu));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text(AppStrings.play), findsOneWidget);
  });
}
