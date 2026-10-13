import 'dart:async';

import 'package:flutter/material.dart';

import '../game/thumbsnakes_game.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/game_config.dart';
import 'menu_button.dart';

/// RF-011: time, best, NEW BEST, RETRY / MENU with a short input lock.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game, required this.onMenu});
  final ThumbsnakesGame game;
  final VoidCallback onMenu;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _enabled = GameConfig.gameOverInputDelaySec <= 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!_enabled) {
      _timer = Timer(
        Duration(
          milliseconds: (GameConfig.gameOverInputDelaySec * 1000).round(),
        ),
        () => mounted ? setState(() => _enabled = true) : null,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    const big = TextStyle(
      color: AppColors.text,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );
    const mid = TextStyle(color: AppColors.text, fontSize: 20);
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.gameOver, style: big),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.time} ${AppStrings.seconds(g.score.elapsed)}',
              style: mid,
            ),
            Text(
              '${AppStrings.highScore} ${AppStrings.seconds(g.highScores.best)}',
              style: mid,
            ),
            if (g.lastWasNewBest)
              const Text(
                AppStrings.newBest,
                style: TextStyle(
                  color: AppColors.snakeB,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuButton(
                  label: AppStrings.retry,
                  onPressed: _enabled ? g.reset : null,
                ),
                MenuButton(
                  label: AppStrings.menu,
                  onPressed: _enabled ? widget.onMenu : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
