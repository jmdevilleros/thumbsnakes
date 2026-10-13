# Thumbsnakes - Plan de Implementación

**Versión:** 1.0  
**Fecha:** 2026-10-12  
**Basado en:** `docs/00_spec.md` v1.1 (Aprobado 2026-10-12)

## Convenciones

- [ ] = Pendiente
- [x] = Completado
- [~] = En progreso

## Reglas de ejecución (ITSD)

1. Leer siempre `docs/00_spec.md`, este plan y `docs/02_decisions.md` al inicio de cada sesión.
2. Completar fases en orden; no avanzar si el checkpoint falla.
3. Toda decisión no cubierta por la spec se documenta como ADR en `02_decisions.md` **antes** de implementarla.
4. No agregar funcionalidades fuera de la spec (comida, power-ups, audio, ajustes…); proponerlas como nueva fase.
5. Código, comentarios e identificadores en **inglés**; UI v1 en inglés vía `app_strings.dart`.
6. Constantes solo en `lib/utils/game_config.dart`; tests llaman a funciones reales (no reimplementan fórmulas).
7. La IA **no** hace commits ni push; el usuario controla Git.
8. Ideal: 1–2 fases por sesión.
9. La IA puede y debe alertar sobre inconsistencias o riesgos.

## Mapa de fases → RF

| Fase | Enfoque | RF principales |
|------|---------|----------------|
| 0 | Scaffold + deps + AGENTS | §1 Tecnologías, §6 Estructura |
| 1 | Config, strings, colores | §5 Parámetros, RNF mantenibilidad |
| 2 | Lógica pura: modelos, tick, colisiones | RF-001, RF-002, RF-004 |
| 3 | Dificultad: crecimiento, velocidad, puntaje | RF-005, RF-006, RF-007 (cálculo) |
| 4 | Render Flame del tablero y culebras | RF-001, RF-002, §4 Estilo |
| 5 | Joysticks fijos + input por mitad | RF-003 |
| 6 | HUD + pantallas (menú, pausa, game over) | RF-008, RF-009, RF-010, RF-011 |
| 7 | Persistencia high score | RF-007 |
| 8 | Polish, tests finales, builds | §3 RNF, §8 Criterios generales |

---

## Fase 0: Scaffold del proyecto

**Objetivo:** Proyecto Flutter compilando en Android y Web, landscape, con dependencias y `AGENTS.md`.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `pubspec.yaml` | Crear (`flutter create`), añadir `flame`, `shared_preferences`, `flutter_lints` |
| `analysis_options.yaml` | Crear / ajustar (flutter_lints) |
| `android/app/build.gradle.kts` | Modificar: applicationId `com.teoktonos.thumbsnakes` |
| `android/app/src/main/AndroidManifest.xml` | Modificar: `screenOrientation="sensorLandscape"`, label Thumbsnakes |
| `lib/main.dart` | Crear: landscape + fullscreen vía `SystemChrome`, app vacía |
| `AGENTS.md` | Crear desde template ITSD (comandos reales) |
| `.gitignore` | Verificar |

### Checklist

- [x] `flutter create . --org com.teoktonos --project-name thumbsnakes --platforms=android,web`
- [x] Añadir dependencias y `flutter pub get`
- [x] Forzar landscape (manifest + `SystemChrome`)
- [x] Crear carpetas `lib/{game,models,managers,screens,widgets,utils}` y `test/`
- [x] Escribir `AGENTS.md`
- [x] Registrar ADR de scaffold si hay desviaciones

### Checkpoint

```bash
flutter pub get && flutter analyze && flutter build web --release
```

---

## Fase 1: Configuración, strings y colores

**Objetivo:** Todos los parámetros de la spec §5 y los textos/colores centralizados.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/utils/game_config.dart` | Crear: todos los parámetros con defaults de §5 |
| `lib/utils/app_strings.dart` | Crear: textos UI en inglés |
| `lib/utils/app_colors.dart` | Crear: fondo, grilla, cian (A), naranja (B), cabezas |
| `test/game_config_test.dart` | Crear: defaults dentro de rangos |

### Checklist

- [x] `GameConfig` con `gridCols=32`, `gridRows=18`, `initialLength=4`, `initialDirection=up`, `startSpeed=4.0`, `speedIncrement=0.5`, `speedIntervalSec=15`, `maxSpeed=12.0`, `growthIntervalSec=10`, `growthAmount=1`, `joystickDeadZone=0.25`, `joystickRadius=60`, `inputBufferSize=1`, `resumeCountdownSec=3`, `gameOverInputDelaySec=0.5`
- [x] Strings: título, PLAY, RESUME, MENU, RETRY, NEW BEST, hint de controles
- [x] Paleta de colores

### Checkpoint

```bash
flutter analyze && flutter test test/game_config_test.dart
```

---

## Fase 2: Lógica pura del juego (modelos, tick, colisiones)

**Objetivo:** Motor de reglas independiente de Flame: dos culebras avanzan por tick, giros válidos y detección de las tres causas de derrota.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/models/direction.dart` | Crear: enum 4 direcciones, `opposite`, vector |
| `lib/models/board.dart` | Crear: dimensiones, `isInside` |
| `lib/models/snake.dart` | Crear: segmentos, dirección, buffer de giros, `pendingGrowth` |
| `lib/managers/game_rules.dart` | Crear: `initialState`, `tick(state) → result` (movimiento simultáneo, colisiones) |
| `test/game_rules_test.dart` | Crear |

### Checklist

- [x] Posiciones iniciales: A en cuarto izquierdo, B en cuarto derecho, ambas hacia arriba, sin colisión en el primer tick
- [x] Giro de 180° ignorado; buffer de 1 giro
- [x] Tick: calcular ambas cabezas nuevas, luego evaluar colisiones
- [x] Colisión con pared, consigo misma, con la otra (cuerpo, cabeza-cabeza, intercambio de cabezas)
- [x] Celda de cola liberada cuenta como libre salvo crecimiento
- [x] Resultado indica qué culebra / celda causó la derrota
- [x] Tests para cada caso anterior

### Checkpoint

```bash
flutter test test/game_rules_test.dart
```

---

## Fase 3: Dificultad y puntaje (crecimiento, velocidad, tiempo)

**Objetivo:** Funciones puras de dificultad en función del tiempo jugado y reloj de partida que excluye pausas.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/managers/difficulty.dart` | Crear: `speedAt(t)`, `growthsDue(t)` |
| `lib/managers/score_manager.dart` | Crear: tiempo sobrevivido (sin pausa), formato `42.3s` |
| `lib/managers/game_rules.dart` | Modificar: aplicar crecimiento a ambas culebras |
| `test/difficulty_test.dart` | Crear |
| `test/score_test.dart` | Crear |

### Checklist

- [x] `speedAt(t) = min(maxSpeed, startSpeed + floor(t/speedIntervalSec) × speedIncrement)`
- [x] Crecimiento de `growthAmount` cada `growthIntervalSec` en ambas culebras
- [x] A los 10 s (defaults) cada culebra mide `initialLength + 1`
- [x] Puntaje no avanza en pausa
- [x] Tests de límites (t=0, escalones, tope `maxSpeed`)

### Checkpoint

```bash
flutter test test/difficulty_test.dart test/score_test.dart
```

---

## Fase 4: Render Flame del tablero y culebras

**Objetivo:** Ver la partida corriendo con input de prueba (teclado web): tablero, grilla, dos culebras, game loop a tick variable.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/game/thumbsnakes_game.dart` | Crear: `FlameGame`, acumulador de tick según `speedAt`, render Canvas |
| `lib/screens/game_screen.dart` | Crear: `GameWidget` |
| `lib/main.dart` | Modificar: abrir `GameScreen` temporalmente |

### Checklist

- [x] Celdas cuadradas escaladas al viewport; tablero completo visible en 16:9–20:9, dejando franja superior para HUD
- [x] Fondo oscuro, grilla tenue, borde visible
- [x] Culebras cian/naranja con cabeza más brillante
- [x] Lógica a tick fijo independiente del FPS
- [x] Teclado de desarrollo: WASD → A, flechas → B
- [x] Al perder: resaltar culebra/celda causante y detener

### Checkpoint

```bash
flutter analyze && flutter run -d chrome
# Manual: ambas culebras avanzan; WASD/flechas giran; chocar pared/cuerpo/otra detiene el juego
```

---

## Fase 5: Joysticks virtuales fijos + input por mitad

**Objetivo:** Control con dos pulgares: joystick fijo abajo-izquierda → A, abajo-derecha → B (ADR-007).

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/widgets/virtual_joystick.dart` | Crear: adaptado de Voideron, posición fija, semitransparente, salida 4 direcciones |
| `lib/managers/input_controller.dart` | Crear: enruta punteros por mitad de pantalla; cuantiza por eje dominante con zona muerta |
| `lib/game/thumbsnakes_game.dart` | Modificar: consumir dirección de cada joystick |
| `test/input_quantize_test.dart` | Crear |

### Checklist

- [x] Joystick A fijo abajo-izquierda, B fijo abajo-derecha, radio `joystickRadius`
- [x] Cualquier toque en una mitad activa su joystick; dirección medida desde el centro fijo
- [x] Cuantización por eje dominante con `joystickDeadZone`
- [x] Multitouch: cada puntero queda asignado a su mitad mientras dure el toque
- [x] Toque en mitad izquierda nunca afecta a B y viceversa
- [x] Tests de cuantización y de asignación por mitad

### Checkpoint

```bash
flutter test test/input_quantize_test.dart && flutter run -d <android_device>
# Manual: dos pulgares simultáneos controlan cada culebra sin interferencia; no hay giro 180°
```

---

## Fase 6: HUD y pantallas (menú, pausa, game over)

**Objetivo:** Flujo completo de pantallas del MVP.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/widgets/game_hud_overlay.dart` | Crear: tiempo, high score, botón pausa centro superior |
| `lib/screens/main_menu_screen.dart` | Crear: THUMBSNAKES, PLAY, high score, hint de controles |
| `lib/widgets/pause_overlay.dart` | Crear: RESUME (cuenta regresiva) / MENU |
| `lib/widgets/game_over_overlay.dart` | Crear: tiempo, high score, NEW BEST, RETRY / MENU, bloqueo 0.5 s |
| `lib/main.dart` | Modificar: arrancar en menú |
| `lib/game/thumbsnakes_game.dart` | Modificar: overlays, pausa por back y por `AppLifecycleState` |

### Checklist

- [x] HUD actualiza el tiempo ≥10 veces/s
- [x] Pausa con botón, botón atrás de Android y app en segundo plano
- [x] RESUME con cuenta regresiva `resumeCountdownSec` (0 = sin cuenta)
- [x] MENU desde pausa abandona sin guardar
- [x] Game Over con bloqueo `gameOverInputDelaySec`; RETRY reinicia; MENU vuelve
- [x] High score en memoria (persistencia en Fase 7)

### Checkpoint

```bash
flutter analyze && flutter run -d <android_device>
# Manual: Menú → PLAY → pausa/resume → derrota → Game Over → RETRY → derrota → MENU
```

---

## Fase 7: Persistencia del high score

**Objetivo:** Récord guardado entre sesiones con `shared_preferences`, fail-soft.

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/managers/high_score_store.dart` | Crear: `load()` / `saveIfBetter()` clave `high_score` |
| `lib/screens/main_menu_screen.dart` | Modificar: mostrar récord guardado |
| `lib/widgets/game_over_overlay.dart` | Modificar: NEW BEST con valor persistido |
| `test/high_score_store_test.dart` | Crear (con `SharedPreferences.setMockInitialValues`) |

### Checklist

- [x] Guardar solo si supera el récord
- [x] Error de persistencia → récord en memoria, sin crash
- [x] Menú muestra `0.0s` si no hay récord

### Checkpoint

```bash
flutter test test/high_score_store_test.dart
# Manual: lograr récord, cerrar la app por completo, reabrir → récord visible
```

---

## Fase 8: Polish, tests finales y builds

**Objetivo:** Cumplir los criterios generales (§8) y RNF (§3).

### Archivos a crear / modificar

| Archivo | Acción |
|---------|--------|
| `lib/**` | Ajustes de legibilidad, contraste, semitransparencia de joysticks |
| `test/**` | Completar cobertura de reglas puras |
| `AGENTS.md` | Actualizar comandos y estructura reales |
| `docs/02_decisions.md` | ADRs de ajustes de balance si los hay |

### Checklist

- [~] 60 FPS estables en Android de gama media (pendiente: verificar en dispositivo real; ADR-010)
- [~] Revisar balance con defaults (defaults sin cambios; ajustar tras prueba en dispositivo)
- [x] Sin permisos de red ni especiales en el manifest
- [~] Ícono / nombre de app "Thumbsnakes" (nombre listo; ícono Flutter por defecto, ADR-010)
- [~] Flujo completo verificado en Android y Web (automatizado con tests de widget/juego + build web; prueba manual en dispositivo pendiente, ADR-010)

### Checkpoint

```bash
flutter analyze && flutter test && flutter build apk --release && flutter build web --release
```
