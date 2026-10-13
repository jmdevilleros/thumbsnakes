import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/thumbsnakes_game.dart';
import '../managers/high_score_store.dart';
import '../managers/input_controller.dart';
import '../models/snake.dart';
import '../utils/app_colors.dart';
import '../utils/game_config.dart';
import '../widgets/game_hud_overlay.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/virtual_joystick.dart';

/// Hosts the Flame game, routes touches by screen half to the fixed
/// joysticks (RF-003, ADR-007) and handles Android back → pause (RF-010).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.highScores});
  final HighScoreStore highScores;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ThumbsnakesGame _game = ThumbsnakesGame(
    highScores: widget.highScores,
  );
  final Map<int, SnakeId> _pointerSide = {};
  final Map<SnakeId, Offset> _knob = {
    SnakeId.a: Offset.zero,
    SnakeId.b: Offset.zero,
  };

  void _goMenu() => Navigator.of(context).pop();

  void _handle(PointerEvent e, Size size) {
    final side = _pointerSide.putIfAbsent(
      e.pointer,
      () => InputController.sideFor(e.localPosition.dx, size.width),
    );
    final delta = e.localPosition - InputController.centerFor(side, size);
    setState(() => _knob[side] = delta);
    final dir = InputController.quantize(delta);
    if (dir != null) _game.steer(side, dir);
  }

  void _release(PointerEvent e) {
    final side = _pointerSide.remove(e.pointer);
    if (side != null && !_pointerSide.containsValue(side)) {
      setState(() => _knob[side] = Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _game.pause();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            const r = GameConfig.joystickRadius;
            final ca = InputController.centerFor(SnakeId.a, size);
            final cb = InputController.centerFor(SnakeId.b, size);
            return Stack(
              children: [
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (e) => _handle(e, size),
                    onPointerMove: (e) => _handle(e, size),
                    onPointerUp: _release,
                    onPointerCancel: _release,
                    child: GameWidget(game: _game, autofocus: true),
                  ),
                ),
                GameHudOverlay(game: _game),
                ValueListenableBuilder<GamePhase>(
                  valueListenable: _game.phase,
                  builder: (_, p, _) => switch (p) {
                    GamePhase.paused => PauseOverlay(
                      game: _game,
                      onMenu: _goMenu,
                    ),
                    GamePhase.over => GameOverOverlay(
                      game: _game,
                      onMenu: _goMenu,
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
                Positioned(
                  left: ca.dx - r,
                  top: ca.dy - r,
                  child: VirtualJoystick(
                    knob: _knob[SnakeId.a]!,
                    tint: AppColors.snakeA,
                  ),
                ),
                Positioned(
                  left: cb.dx - r,
                  top: cb.dy - r,
                  child: VirtualJoystick(
                    knob: _knob[SnakeId.b]!,
                    tint: AppColors.snakeB,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
