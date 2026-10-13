# Thumbsnakes - Reglas para Agentes IA

## Overview

Thumbsnakes is a landscape Android arcade game (Web secondary, for dev): one
player steers **two snakes at once**, one per thumb, each with a **fixed**
on-screen virtual joystick (left half → snake A cyan, right half → snake B
orange). Classic 4-direction grid, shared board, no food. Lose if any snake hits
a wall, itself or the other snake. Score = time survived; persistent high score.
Snakes grow every N seconds and speed increases over time.

Spec: `docs/00_spec.md` v1.1 (approved). Plan: `docs/01_plan.md`.
Decisions: `docs/02_decisions.md`.

## Tech Stack

- Flutter 3.x (stable; scaffolded with 3.47.7) / Dart 3.x
- Flame (game loop / rendering)
- shared_preferences (high score key: `high_score`)
- flutter_lints
- Targets: Android (primary, `com.teoktonos.thumbsnakes`, landscape), Web (secondary / dev)

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter run -d <android_device>
flutter build web --release
flutter build apk --release   # Android SDK at ~/Android, JDK 21 (debug-signed)
```

## Project Structure

```
lib/
  main.dart            # landscape lock + app entry
  game/                # FlameGame (thumbsnakes_game.dart)
  models/              # direction, board (GridPoint), snake
  managers/            # game rules, difficulty, score, high score, input
  screens/             # main menu, game
  widgets/             # virtual joystick layer, HUD, pause, game over, menu button
  utils/               # game_config, app_strings, app_colors
test/                  # unit tests of pure rules
docs/                  # 00_spec, 01_plan, 02_decisions (ITSD)
android/  web/
```

## Code Conventions

- Identifiers, comments and source in **English**
- UI strings in English via `lib/utils/app_strings.dart`
- All tunable constants only in `lib/utils/game_config.dart`
- Pure rules (movement, collisions, growth, speed, score) live in `models/` and
  `managers/`, independent from Flame, and are unit-tested
- Naming: `lowerCamelCase` members, `UpperCamelCase` types, `snake_case.dart` files

## Testing Strategy

- Framework: `flutter_test`
- Test: tick/movement, 180° turn rejection, the three loss causes, growth,
  `speedAt(t)`, score excluding pause, joystick quantization, high score store
- Do **not** re-implement formulas inside tests; call shipped functions
- Manual: full flow on Android with two thumbs

## Architecture Notes

- Fixed-step logic tick (rate from `speedAt(t)`) independent of render FPS
- Both snakes move in the same tick; compute both new heads, then evaluate collisions
- HUD/pause/game over are Flutter widgets stacked over `GameWidget`, driven by the game's `ValueNotifier`s (ADR-010)
- Fixed joysticks (ADR-007): pointer routed by screen half; direction from fixed center, dominant axis + dead zone

## Prohibiciones

- Never commit, push or run destructive git commands (user controls Git)
- No features outside the spec (food, power-ups, audio, settings, ads, network…)
- No magic numbers outside `game_config.dart`
- Do not edit `docs/00_spec.md` without user approval

## Reglas Obligatorias

1. **Lectura de Documentos Base**
   Antes de cualquier acción, leer siempre:
   - `docs/00_spec.md`
   - `docs/01_plan.md`
   - `docs/02_decisions.md`

2. **Autorización para Cuestionar**
   Tienes permiso explícito para alertar sobre inconsistencias, riesgos o mejoras.

3. **Ejecución por fases**
   Seguir el plan en orden, verificar el checkpoint de cada fase antes de avanzar,
   y documentar en ADR toda decisión no cubierta por la spec.
