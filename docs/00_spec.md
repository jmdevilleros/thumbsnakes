# Thumbsnakes - Especificación Detallada

**Versión:** 1.1  
**Fecha:** 2026-10-12  
**Estado:** Aprobado

Juego arcade de supervivencia para Android: un solo jugador controla **dos culebritas a la vez**, una con cada pulgar, sobre un mismo tablero clásico en grilla. No hay comida: las culebras crecen solas con el tiempo y la velocidad aumenta. Gana quien sobreviva más tiempo.

**Alcance de esta versión:** MVP mínimo jugable de principio a fin (menú → partida → pausa → game over con puntaje y high score persistente). Sin online, sin anuncios, sin compras, sin assets externos obligatorios (render con Canvas), sin audio obligatorio, sin pantallas extra (ajustes, estadísticas, about quedan fuera).

### Decisiones de Fase 0 (Captura de Intención, 2026-10-12)

| # | Tema | Decisión |
|---|------|----------|
| 1 | Nombre | **Thumbsnakes** |
| 2 | Plataformas | **Android** primario; **Web** secundario (desarrollo / verificación) |
| 3 | Orientación | **Landscape** forzado |
| 4 | Stack | Flutter 3.x + Dart 3.x + **Flame**; `shared_preferences`; `flutter_lints` |
| 5 | Controles | Dos joysticks virtuales **fijos**: mitad izquierda → culebra A, mitad derecha → culebra B (enfoque de `virtual_joystick` de Voideron) |
| 14 | Dirección inicial / colores | `up`; A cian, B naranja (aceptados) |
| 6 | Movimiento | Grilla clásica, **4 direcciones** |
| 7 | Tablero | **Uno compartido** por ambas culebras |
| 8 | Comida | **No hay** |
| 9 | Derrota | Cualquier culebra choca con pared, consigo misma o con la otra |
| 10 | Victoria / puntaje | Supervivencia infinita; **puntaje = tiempo sobrevivido**; high score persistente |
| 11 | Dificultad | Crecimiento automático cada N s + velocidad creciente (parámetros configurables) |
| 12 | Pantallas MVP | Menú, Juego, Pausa, Game Over |
| 13 | applicationId | `com.teoktonos.thumbsnakes` |

---

## 1. Tecnologías

- **Motor:** Flutter 3.x + Flame  
- **Lenguaje:** Dart 3.x  
- **Persistencia:** shared_preferences (clave `high_score`)  
- **Lint:** flutter_lints  
- **Audio:** fuera de alcance en v1 (arquitectura no debe impedir añadirlo)  
- **Targets de build:** Android (primario, applicationId `com.teoktonos.thumbsnakes`) y Web (secundario)  
- **Tests:** `flutter_test` (unitarios de lógica pura: movimiento, colisiones, crecimiento, velocidad, puntaje) + verificación manual en dispositivo  
- **i18n:** strings de UI centralizados en `lib/utils/app_strings.dart`; v1 en inglés

---

## 2. Requerimientos Funcionales

### RF-001 - Tablero en grilla

**Descripción:**  
Un único tablero rectangular de celdas cuadradas, compartido por ambas culebras, rodeado por paredes.

| Concepto | Valor |
|----------|-------|
| Tamaño lógico | `gridCols × gridRows` (default 32 × 18) |
| Celda | Cuadrada; tamaño derivado del viewport para que el tablero quepa completo en landscape |
| Bordes | Paredes en todo el perímetro (no hay wrap-around) |
| Obstáculos internos | Ninguno en v1 |
| Render | Canvas: fondo oscuro, grilla sutil, borde visible |

**Criterios de aceptación:**
- El tablero completo es visible sin scroll en landscape en teléfonos 16:9 a 20:9.
- Las celdas son cuadradas en cualquier resolución soportada.
- Salir del tablero es imposible sin provocar derrota (RF-004).

### RF-002 - Dos culebras simultáneas

**Descripción:**  
Al iniciar la partida aparecen dos culebras (A y B) con colores claramente distintos.

- **Culebra A** (izquierda, color cian por defecto) y **Culebra B** (derecha, color naranja por defecto).
- Largo inicial: `initialLength` celdas.
- Posición inicial: A en el cuarto izquierdo del tablero, B en el cuarto derecho, separadas y sin tocar paredes.
- Dirección inicial: **ambas hacia arriba** (para no ir una contra la otra); configurable con `initialDirection` (default `up`).
- Ambas avanzan en el mismo *tick* de juego (movimiento discreto celda a celda).

**Criterios de aceptación:**
- Las dos culebras son distinguibles a simple vista (color de cuerpo y cabeza).
- En el primer tick ninguna colisiona.
- Ambas se mueven sincronizadas, una celda por tick.

### RF-003 - Controles virtuales (uno por pulgar)

**Descripción:**  
La pantalla se divide en dos zonas táctiles: **mitad izquierda controla A**, **mitad derecha controla B**. Cada zona tiene su propio control virtual (enfoque de `virtual_joystick` de Voideron), cuantizado a **4 direcciones** (arriba, abajo, izquierda, derecha).

- **Joystick fijo** (ADR-007): posición fija, uno por mitad de pantalla — A en la esquina inferior izquierda, B en la esquina inferior derecha. Tocar cualquier punto de la mitad correspondiente activa su joystick; la dirección se mide desde el centro fijo del joystick.
- La dirección se toma del eje dominante del desplazamiento, con zona muerta `joystickDeadZone`.
- **Giro de 180° prohibido:** pedir la dirección opuesta a la actual se ignora.
- Buffer de 1 giro por culebra: si se piden dos giros antes de un tick, se conserva el último válido (configurable `inputBufferSize`, default 1).
- Multitouch: ambos controles funcionan a la vez e independientes.
- Web: soporte pointer; teclado opcional (WASD para A, flechas para B) solo para desarrollo.

**Criterios de aceptación:**
- Dos dedos simultáneos controlan cada uno su culebra sin interferencia.
- Un toque en la mitad izquierda nunca afecta a B y viceversa.
- El giro de 180° nunca ocurre.
- Los controles no tapan la vista de las cabezas de forma permanente (semitransparentes).

### RF-004 - Colisiones y derrota

**Descripción:**  
La partida termina inmediatamente si **cualquier** culebra:
1. Choca con una pared (sale del tablero).
2. Choca con su propio cuerpo.
3. Choca con el cuerpo o la cabeza de la otra culebra (incluye cabeza contra cabeza y cruce de cabezas en el mismo tick).

Reglas de evaluación por tick: se calculan ambas cabezas nuevas y luego se evalúan colisiones contra el estado resultante. La celda de la cola que se libera en ese tick cuenta como libre (salvo que la culebra crezca en ese tick).

**Criterios de aceptación:**
- Cada uno de los casos 1-3 produce Game Over (cubierto por tests unitarios).
- Intercambio de posiciones de cabezas en un mismo tick cuenta como choque.
- Al perder se resalta la culebra/celda que causó la derrota antes de mostrar Game Over.

### RF-005 - Crecimiento automático

**Descripción:**  
No hay comida. Cada `growthIntervalSec` segundos de juego, **ambas** culebras crecen `growthAmount` segmentos (la cola no avanza durante los ticks necesarios).

**Criterios de aceptación:**
- Con defaults, a los 10 s cada culebra mide `initialLength + 1`.
- El crecimiento ocurre simultáneamente en ambas.
- El tiempo en pausa no cuenta.

### RF-006 - Velocidad creciente

**Descripción:**  
La velocidad (ticks por segundo) empieza en `startSpeed` y aumenta `speedIncrement` cada `speedIntervalSec`, hasta `maxSpeed`.

**Criterios de aceptación:**
- Velocidad en el tiempo t = `min(maxSpeed, startSpeed + floor(t / speedIntervalSec) × speedIncrement)` (función pura testeada).
- Nunca supera `maxSpeed`.

### RF-007 - Puntaje y high score

**Descripción:**  
Puntaje = **tiempo sobrevivido** en segundos (mostrado con 1 decimal, p. ej. `42.3s`). El high score se guarda localmente con shared_preferences.

**Criterios de aceptación:**
- El tiempo en pausa no suma.
- Si el puntaje supera al récord, se guarda y se marca como **NEW BEST** en Game Over.
- El récord persiste tras cerrar y reabrir la app.
- Si la persistencia falla, el juego sigue (récord en memoria).

### RF-008 - HUD

**Descripción:**  
Durante el juego se muestran: tiempo actual, high score y botón de pausa. Ubicados en la franja superior, sin cubrir el tablero de forma significativa.

**Criterios de aceptación:**
- Tiempo se actualiza al menos 10 veces por segundo.
- Botón de pausa accesible con cualquiera de los pulgares sin soltar el otro control de forma prolongada (centro superior).

### RF-009 - Menú principal

**Descripción:**  
Pantalla inicial con título **THUMBSNAKES**, botón **PLAY**, high score actual y una indicación breve de controles ("Left thumb: left snake · Right thumb: right snake").

**Criterios de aceptación:**
- PLAY inicia una partida nueva.
- Se muestra el high score guardado (o `0.0s`).

### RF-010 - Pausa

**Descripción:**  
El botón de pausa (y el botón atrás de Android / pérdida de foco de la app) congela el juego y muestra overlay con **RESUME** y **MENU**.

**Criterios de aceptación:**
- Al pasar la app a segundo plano, se pausa automáticamente.
- RESUME continúa exactamente donde quedó, con una cuenta regresiva corta (`resumeCountdownSec`, default 3; 0 = sin cuenta).
- MENU abandona la partida sin guardar puntaje.

### RF-011 - Game Over

**Descripción:**  
Overlay/pantalla con: tiempo sobrevivido, high score, indicador NEW BEST si aplica, botones **RETRY** y **MENU**.

**Criterios de aceptación:**
- RETRY inicia una partida nueva inmediatamente.
- MENU vuelve al menú principal.
- Los botones no responden durante los primeros `gameOverInputDelaySec` (default 0.5 s) para evitar toques accidentales de los pulgares.

---

## 3. Requerimientos No Funcionales

- **Rendimiento:** 60 FPS de render estable en Android de gama media (lógica a tick fijo independiente del FPS).  
- **Latencia de input:** el giro solicitado se aplica en el siguiente tick.  
- **Compatibilidad:** Android minSdk por defecto de Flutter; Web Chrome actual para desarrollo.  
- **Usabilidad:** jugable con dos pulgares en teléfono horizontal; zonas táctiles grandes; colores con buen contraste (distinguibles también para daltonismo común: cian vs naranja).  
- **Robustez:** fallo de persistencia no rompe el juego.  
- **Privacidad:** sin red, sin recolección de datos, sin permisos especiales.  
- **Mantenibilidad:** constantes de juego solo en `lib/utils/game_config.dart`; lógica pura separada del render y testeada.

---

## 4. Estilo Visual

- Minimalista, Canvas geométrico: fondo oscuro, grilla tenue, culebras en colores neón (A cian, B naranja), cabezas con tono más brillante.  
- Controles virtuales semitransparentes.  
- Sin assets externos obligatorios.

---

## 5. Configuración y Parámetros

Todos en `lib/utils/game_config.dart`.

| Parámetro | Descripción | Valor por defecto | Rango / Opciones |
|-----------|-------------|-------------------|------------------|
| `gridCols` | Columnas del tablero | 32 | 20 – 48 |
| `gridRows` | Filas del tablero | 18 | 12 – 27 |
| `initialLength` | Largo inicial de cada culebra (celdas) | 4 | 2 – 10 |
| `initialDirection` | Dirección inicial de ambas | `up` | up / down / left / right |
| `startSpeed` | Velocidad inicial (ticks/s) | 4.0 | 2.0 – 10.0 |
| `speedIncrement` | Aumento de velocidad por escalón (ticks/s) | 0.5 | 0.1 – 2.0 |
| `speedIntervalSec` | Segundos entre aumentos de velocidad | 15 | 5 – 60 |
| `maxSpeed` | Velocidad máxima (ticks/s) | 12.0 | 6.0 – 20.0 |
| `growthIntervalSec` | Segundos entre crecimientos | 10 | 3 – 60 |
| `growthAmount` | Segmentos añadidos por crecimiento | 1 | 1 – 3 |
| `joystickDeadZone` | Zona muerta del control (fracción del radio) | 0.25 | 0.1 – 0.5 |
| `joystickRadius` | Radio del control (dp) | 60 | 40 – 100 |
| `inputBufferSize` | Giros en cola por culebra | 1 | 1 – 2 |
| `resumeCountdownSec` | Cuenta regresiva al reanudar | 3 | 0 – 5 |
| `gameOverInputDelaySec` | Bloqueo de botones en Game Over | 0.5 | 0 – 2 |
| `snakeAColor` / `snakeBColor` | Colores de culebras | cian / naranja | cualquier color |

---

## 6. Estructura de Archivos (Inicial)

```
thumbsnakes/
  AGENTS.md                 # Fase 3 (tras scaffold)
  pubspec.yaml
  analysis_options.yaml
  android/                  # applicationId com.teoktonos.thumbsnakes, landscape
  web/
  docs/
    00_spec.md
    01_plan.md
    02_decisions.md
  lib/
    main.dart
    game/thumbsnakes_game.dart        # FlameGame: loop, tick, render
    models/
      direction.dart
      snake.dart                      # segmentos, dirección, buffer
      board.dart
    managers/
      game_rules.dart                 # tick puro: mover, crecer, colisiones
      difficulty.dart                 # velocidad y crecimiento vs tiempo
      score_manager.dart
      high_score_store.dart           # shared_preferences
      input_controller.dart           # mitad izq/der → culebra A/B
    screens/
      main_menu_screen.dart
      game_screen.dart
    widgets/
      virtual_joystick.dart           # adaptado de Voideron, 4 direcciones
      game_hud_overlay.dart
      pause_overlay.dart
      game_over_overlay.dart
    utils/
      game_config.dart
      app_strings.dart
      app_colors.dart
  test/
    game_rules_test.dart
    difficulty_test.dart
    score_test.dart
    input_quantize_test.dart
```

---

## 7. Restricciones Técnicas

- Sin comida, power-ups, obstáculos internos ni modos extra en v1.  
- Sin red, anuncios, compras, cuentas ni analítica.  
- Sin multijugador (un solo jugador, dos culebras).  
- Movimiento estrictamente en grilla y 4 direcciones (nada de movimiento libre/analógico).  
- Constantes solo en `game_config.dart`; los tests llaman a las funciones reales (no reimplementan fórmulas).  
- La IA no hace commits; el usuario controla Git.

---

## 8. Criterios de Aceptación Generales

- Flujo completo funciona en Android: Menú → PLAY → juego → pausa/resume → derrota → Game Over → RETRY / MENU.  
- Dos culebras controladas simultáneamente con dos pulgares, sin interferencia.  
- Las tres causas de derrota funcionan y están cubiertas por tests.  
- Crecimiento y velocidad siguen los parámetros de la tabla §5.  
- High score persiste entre sesiones.  
- `flutter analyze` sin errores; `flutter test` en verde; `flutter build apk` y `flutter build web` exitosos.

---

## 9. Checklist: Spec lista para plan ITSD

- [x] Decisiones de Fase 0 registradas (tabla inicial + `docs/02_decisions.md`)
- [x] RF con criterios de aceptación
- [x] Parámetros con defaults y rangos
- [x] Estructura de archivos
- [x] Aprobación del usuario

**Aprobación del Usuario:**  
- [x] Aprobado por el usuario en fecha: 2026-10-12 (v1.1: joysticks fijos)
