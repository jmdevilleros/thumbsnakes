# Thumbsnakes - Decisiones de Arquitectura y Diseño (ADR)

Registro de decisiones importantes tomadas durante el desarrollo del proyecto.

## Convenciones

- **ID**: ADR-XXX
- **Fecha**: YYYY-MM-DD
- **Estado**: Propuesta | Aceptada | Rechazada | Obsoleta | Modificada

---

## Decisiones

### ADR-001 - 2026-10-12 - Nombre: Thumbsnakes

**Estado**: Aceptada

**Contexto**: Se necesitaba un nombre corto y original sin duplicados en Google Play / GitHub.

**Decisión**: "Thumbsnakes" (repo `jmdevilleros/thumbsnakes`, privado; applicationId sugerido `com.teoktonos.thumbsnakes`).

**Alternativas consideradas**:
- Twinsnake: ya existen "Twin Snake – Arcade" (SmartPlayland) y "Twin Snakes" (MathSlice) en Play.
- Duoboa, Twinzle, Snakelings: menos descriptivos o con coincidencias.

**Consecuencias**:
- **Positivas**: describe la mecánica (un pulgar por culebra); sin colisión encontrada.
- **Negativas / Riesgos**: búsqueda no exhaustiva; verificar en Play Console antes de publicar.
- **Requiere cambios en**: —

---

### ADR-002 - 2026-10-12 - Stack: Flutter + Flame, Android primario

**Estado**: Aceptada

**Contexto**: Juego 2D móvil; Juan ya tiene experiencia y código reutilizable en Voideron.

**Decisión**: Flutter 3.x + Dart 3.x + Flame; shared_preferences; flutter_lints. Android primario, Web secundario para desarrollo. Landscape forzado.

**Alternativas consideradas**:
- Kotlin nativo (como voideron_proto): sin target web rápido para iterar.
- Unity/Godot: sobredimensionado para el MVP.

**Consecuencias**:
- **Positivas**: reutilización de `virtual_joystick`, estructura y prácticas de Voideron.
- **Negativas / Riesgos**: multitouch en Web limitado a desarrollo.
- **Requiere cambios en**: —

---

### ADR-003 - 2026-10-12 - Un jugador, dos culebras, un control por mitad de pantalla

**Estado**: Aceptada

**Contexto**: El concepto central es coordinar dos culebras a la vez con dos pulgares.

**Decisión**: Mitad izquierda de la pantalla → culebra A; mitad derecha → culebra B. Cada mitad tiene su control virtual (enfoque de Voideron) cuantizado a 4 direcciones; giro de 180° prohibido.

**Alternativas consideradas**:
- Botones D-pad fijos: menos fluidos en pantalla táctil.
- Swipe por mitad: posible variante futura.

**Consecuencias**:
- **Positivas**: control independiente y simultáneo.
- **Negativas / Riesgos**: los pulgares pueden tapar parte del tablero → controles semitransparentes.
- **Requiere cambios en**: RF-003.

---

### ADR-004 - 2026-10-12 - Grilla clásica de 4 direcciones y tablero compartido

**Estado**: Aceptada

**Contexto**: Fidelidad al Snake clásico y simplicidad del MVP.

**Decisión**: Movimiento discreto por ticks en grilla cuadrada, 4 direcciones; ambas culebras en un único tablero con paredes perimetrales.

**Alternativas consideradas**:
- Movimiento libre/analógico (estilo slither): más complejo, se aleja del clásico.
- Tableros separados por culebra: elimina la interacción entre culebras.

**Consecuencias**:
- **Positivas**: lógica pura simple y testeable.
- **Negativas / Riesgos**: —
- **Requiere cambios en**: RF-001, RF-002.

---

### ADR-005 - 2026-10-12 - Sin comida; supervivencia infinita con dificultad por tiempo

**Estado**: Aceptada

**Contexto**: Con dos culebras, buscar comida añade carga cognitiva; el reto es coordinar y sobrevivir.

**Decisión**: No hay comida. Derrota si cualquier culebra choca con pared, consigo misma o con la otra. Puntaje = tiempo sobrevivido; high score persistente. Las culebras crecen cada `growthIntervalSec` y la velocidad sube cada `speedIntervalSec` hasta `maxSpeed`.

**Alternativas consideradas**:
- Comida compartida o por culebra: descartada para el MVP.
- Niveles con objetivo: más alcance del necesario.

**Consecuencias**:
- **Positivas**: reglas simples; partidas cortas e intensas.
- **Negativas / Riesgos**: el balance depende de los parámetros → ajustar en pruebas y registrar en nuevos ADR.
- **Requiere cambios en**: RF-004 a RF-007.

---

### ADR-006 - 2026-10-12 - Alcance mínimo de pantallas

**Estado**: Aceptada

**Contexto**: El MVP debe ser lo más pequeño posible pero completo.

**Decisión**: Solo Menú, Juego (con HUD), Pausa y Game Over. Sin ajustes, estadísticas, audio ni about en v1.

**Alternativas consideradas**:
- Copiar todas las pantallas de Voideron: fuera de alcance.

**Consecuencias**:
- **Positivas**: entrega rápida.
- **Negativas / Riesgos**: se agregarán pantallas en una fase de refinamiento (docs 03/04, como en Voideron).
- **Requiere cambios en**: RF-008 a RF-011.

---

### ADR-007 - 2026-10-12 - Joysticks virtuales fijos

**Estado**: Aceptada

**Contexto**: En la revisión de la spec v1.0 quedaba abierto si los joysticks serían dinámicos (aparecen donde toca el pulgar) o fijos.

**Decisión**: Joysticks **fijos**, uno por mitad de pantalla: A abajo a la izquierda y B abajo a la derecha. La dirección se calcula desde el centro fijo y se cuantiza a 4 direcciones. También se aceptan la dirección inicial `up` y los colores cian (A) / naranja (B).

**Alternativas consideradas**:
- Joystick dinámico: más tolerante a la posición del pulgar, pero menos predecible y con menos referencia visual.

**Consecuencias**:
- **Positivas**: posición predecible, más fácil de aprender y de testear; reutiliza directamente el widget de Voideron.
- **Negativas / Riesgos**: los pulgares tapan las esquinas inferiores del tablero → joysticks semitransparentes y `joystickRadius` configurable.
- **Requiere cambios en**: RF-003 (spec v1.1).

---

### ADR-008 - 2026-10-12 - Scaffold Flutter in-place en el repo existente

**Estado**: Aceptada

**Contexto**: El repo `thumbsnakes` ya tenía `README.md`, `.gitignore` (Dart/Flutter, creado por el bot de GitHub) y `docs/`.

**Decisión**: `flutter create . --org com.teoktonos --project-name thumbsnakes --platforms=android,web` en la raíz con Flutter stable 3.47.7 / Dart 3.13.5, sin sobrescribir `README.md` ni `.gitignore`. Dependencias: `flame ^1.38.2`, `shared_preferences ^2.5.6`, `flutter_lints ^6.0.0`. Landscape vía `android:screenOrientation="sensorLandscape"` + `SystemChrome` (landscape + immersiveSticky). El test por defecto se reemplazó por un smoke test del shell vacío.

**Alternativas consideradas**:
- Subcarpeta `app/`: rechazada para respetar la estructura de la spec §6.

**Consecuencias**:
- **Positivas**: estructura ITSD estándar, igual que Voideron.
- **Negativas / Riesgos**: el `.gitignore` existente ignora `pubspec.lock` (plantilla de paquetes Dart); para una app se recomienda versionarlo → decisión del usuario.
- **Requiere cambios en**: —
