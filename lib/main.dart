import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ThumbsnakesApp());
}

/// Phase 0 shell: empty app. Screens arrive in later phases (see docs/01_plan.md).
class ThumbsnakesApp extends StatelessWidget {
  const ThumbsnakesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thumbsnakes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(backgroundColor: Colors.black),
    );
  }
}
