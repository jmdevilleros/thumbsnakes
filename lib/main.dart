import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'managers/high_score_store.dart';
import 'screens/main_menu_screen.dart';
import 'utils/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(ThumbsnakesApp());
}

class ThumbsnakesApp extends StatelessWidget {
  ThumbsnakesApp({super.key, HighScoreStore? highScores})
    : highScores = highScores ?? HighScoreStore();

  final HighScoreStore highScores;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MainMenuScreen(highScores: highScores),
    );
  }
}
