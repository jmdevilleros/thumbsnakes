import 'package:flutter/material.dart';

import '../game/thumbsnakes_game.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import 'menu_button.dart';

/// RF-010: RESUME (with countdown) / MENU (abandon without saving).
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game, required this.onMenu});
  final ThumbsnakesGame game;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black54,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppStrings.paused,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MenuButton(label: AppStrings.resume, onPressed: game.resume),
              MenuButton(label: AppStrings.menu, onPressed: onMenu),
            ],
          ),
        ],
      ),
    ),
  );
}
