import 'package:flutter/material.dart';

import '../game/thumbsnakes_game.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/game_config.dart';

/// RF-008: time, best and pause button in the top band.
class GameHudOverlay extends StatelessWidget {
  const GameHudOverlay({super.key, required this.game});
  final ThumbsnakesGame game;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.text,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: GameConfig.hudHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: game.elapsed,
              builder: (_, t, _) => Text(
                '${AppStrings.time} ${AppStrings.seconds(t)}',
                style: style,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              key: const Key('pauseButton'),
              icon: const Icon(
                Icons.pause_circle_outline,
                color: AppColors.text,
              ),
              iconSize: 32,
              onPressed: game.pause,
            ),
            const SizedBox(width: 16),
            Text(
              '${AppStrings.highScore} ${AppStrings.seconds(game.highScores.best)}',
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}
