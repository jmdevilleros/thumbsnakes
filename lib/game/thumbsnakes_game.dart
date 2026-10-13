import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../managers/difficulty.dart';
import '../managers/game_rules.dart';
import '../managers/high_score_store.dart';
import '../managers/score_manager.dart';
import '../models/direction.dart';
import '../models/snake.dart';
import '../utils/app_colors.dart';
import '../utils/game_config.dart';

/// `dying` = loss highlight for [GameConfig.lossHighlightSec] before Game Over.
enum GamePhase { countdown, running, paused, dying, saving, over }

/// HUD / pause / game over are Flutter widgets driven by [phase] (ADR-010).
/// Flame game: fixed-step logic tick (rate from [Difficulty.speedAt])
/// independent of render FPS, Canvas rendering, pause and game over.
class ThumbsnakesGame extends FlameGame with KeyboardEvents {
  ThumbsnakesGame({HighScoreStore? highScores})
    : highScores = highScores ?? HighScoreStore();

  final HighScoreStore highScores;
  final ScoreManager score = ScoreManager();

  /// Notifies HUD / overlays (elapsed time, phase).
  final ValueNotifier<double> elapsed = ValueNotifier(0);
  final ValueNotifier<GamePhase> phase = ValueNotifier(GamePhase.running);
  bool lastWasNewBest = false;

  late GameState state;
  double _acc = 0;
  int _growthsApplied = 0;
  double _countdown = 0;
  double _dying = 0;
  double _hudAcc = 0;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    reset();
  }

  void reset() {
    state = GameRules.initialState();
    score.reset();
    elapsed.value = 0;
    _acc = 0;
    _growthsApplied = 0;
    _countdown = 0;
    _dying = 0;
    _hudAcc = 0;
    lastWasNewBest = false;
    phase.value = GamePhase.running;
  }

  void steer(SnakeId id, Direction d) {
    if (phase.value != GamePhase.running &&
        phase.value != GamePhase.countdown &&
        phase.value != GamePhase.paused) {
      return;
    }
    state.snake(id).requestTurn(d);
  }

  void pause() {
    if (phase.value != GamePhase.running &&
        phase.value != GamePhase.countdown) {
      return;
    }
    phase.value = GamePhase.paused;
  }

  void resume() {
    if (phase.value != GamePhase.paused) return;
    _countdown = GameConfig.resumeCountdownSec;
    phase.value = _countdown > 0 ? GamePhase.countdown : GamePhase.running;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    if (state != AppLifecycleState.resumed) pause();
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (phase.value) {
      case GamePhase.countdown:
        _countdown -= dt;
        if (_countdown <= 0) phase.value = GamePhase.running;
      case GamePhase.running:
        _step(dt);
      case GamePhase.dying:
        _dying -= dt;
        if (_dying <= 0 && phase.value == GamePhase.dying) {
          phase.value = GamePhase.saving;
          _finish();
        }
      case GamePhase.paused:
      case GamePhase.saving:
      case GamePhase.over:
        break;
    }
  }

  void _step(double dt) {
    score.advance(dt, running: true);
    _hudAcc += dt;
    if (_hudAcc >= GameConfig.hudRefreshSec) {
      _hudAcc = 0;
      elapsed.value = score.elapsed;
    }
    final due = Difficulty.growthsDue(score.elapsed);
    if (due > _growthsApplied) {
      GameRules.grow(state, (due - _growthsApplied) * GameConfig.growthAmount);
      _growthsApplied = due;
    }
    _acc += dt;
    final interval = 1 / Difficulty.speedAt(score.elapsed);
    while (_acc >= interval && !state.isOver) {
      _acc -= interval;
      GameRules.tick(state);
    }
    if (state.isOver) {
      elapsed.value = score.elapsed;
      phase.value = GamePhase.dying;
      _dying = GameConfig.lossHighlightSec;
    }
  }

  Future<void> _finish() async {
    lastWasNewBest = await highScores.saveIfBetter(score.elapsed);
    phase.value = GamePhase.over;
  }

  // ---- Rendering -----------------------------------------------------------

  ({double cell, Offset origin}) layout() {
    final w = size.x, h = size.y - GameConfig.hudHeight;
    final cell = math.min(w / state.board.cols, h / state.board.rows);
    final bw = cell * state.board.cols, bh = cell * state.board.rows;
    return (
      cell: cell,
      origin: Offset((w - bw) / 2, GameConfig.hudHeight + (h - bh) / 2),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final (:cell, :origin) = layout();
    final cols = state.board.cols, rows = state.board.rows;
    final boardRect = Rect.fromLTWH(
      origin.dx,
      origin.dy,
      cell * cols,
      cell * rows,
    );

    final gridPaint = Paint()
      ..color = AppColors.grid
      ..strokeWidth = 1;
    for (var x = 1; x < cols; x++) {
      final px = origin.dx + x * cell;
      canvas.drawLine(
        Offset(px, boardRect.top),
        Offset(px, boardRect.bottom),
        gridPaint,
      );
    }
    for (var y = 1; y < rows; y++) {
      final py = origin.dy + y * cell;
      canvas.drawLine(
        Offset(boardRect.left, py),
        Offset(boardRect.right, py),
        gridPaint,
      );
    }
    canvas.drawRect(
      boardRect,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    void drawSnake(Snake s, Color body, Color head) {
      final inset = cell * 0.08;
      for (var i = s.body.length - 1; i >= 0; i--) {
        final c = s.body[i];
        if (!state.board.isInside(c)) continue;
        final r = Rect.fromLTWH(
          origin.dx + c.x * cell + inset,
          origin.dy + c.y * cell + inset,
          cell - 2 * inset,
          cell - 2 * inset,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(cell * 0.2)),
          Paint()..color = i == 0 ? head : body,
        );
      }
    }

    drawSnake(state.a, AppColors.snakeA, AppColors.snakeAHead);
    drawSnake(state.b, AppColors.snakeB, AppColors.snakeBHead);

    // RF-004: highlight the losing cell(s).
    for (final l in state.losses) {
      final cx = l.cell.x.clamp(-1, cols), cy = l.cell.y.clamp(-1, rows);
      final r = Rect.fromLTWH(
        origin.dx + cx * cell,
        origin.dy + cy * cell,
        cell,
        cell,
      );
      canvas.drawRect(
        r,
        Paint()
          ..color = AppColors.loss
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (phase.value == GamePhase.countdown) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${_countdown.ceil()}',
          style: TextStyle(
            color: AppColors.text,
            fontSize: cell * 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, boardRect.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  // ---- Dev keyboard (web): WASD → A, arrows → B ----------------------------

  static final _keys = {
    LogicalKeyboardKey.keyW: (SnakeId.a, Direction.up),
    LogicalKeyboardKey.keyS: (SnakeId.a, Direction.down),
    LogicalKeyboardKey.keyA: (SnakeId.a, Direction.left),
    LogicalKeyboardKey.keyD: (SnakeId.a, Direction.right),
    LogicalKeyboardKey.arrowUp: (SnakeId.b, Direction.up),
    LogicalKeyboardKey.arrowDown: (SnakeId.b, Direction.down),
    LogicalKeyboardKey.arrowLeft: (SnakeId.b, Direction.left),
    LogicalKeyboardKey.arrowRight: (SnakeId.b, Direction.right),
  };

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final hit = _keys[event.logicalKey];
    if (hit == null) return KeyEventResult.ignored;
    steer(hit.$1, hit.$2);
    return KeyEventResult.handled;
  }
}
