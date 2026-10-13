import 'package:flutter/material.dart';

import '../managers/high_score_store.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/menu_button.dart';
import 'game_screen.dart';

/// RF-009: title, PLAY, best time, controls hint.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.highScores});
  final HighScoreStore highScores;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    widget.highScores.load().then((_) => mounted ? setState(() {}) : null);
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(highScores: widget.highScores),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
                children: [
                  TextSpan(
                    text: 'THUMB',
                    style: TextStyle(color: AppColors.snakeA),
                  ),
                  TextSpan(
                    text: 'SNAKES',
                    style: TextStyle(color: AppColors.snakeB),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MenuButton(label: AppStrings.play, onPressed: _play),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.highScore} ${AppStrings.seconds(widget.highScores.best)}',
              style: const TextStyle(color: AppColors.text, fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.controlsHint,
              style: TextStyle(color: AppColors.text, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
