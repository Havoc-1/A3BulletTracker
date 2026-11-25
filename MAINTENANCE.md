# Spotter Bullet Tracker: Codebase Maintenance Guide

This document is the technical architecture and maintenance reference for SBT.

---

## 1. Architectural Overview

```
+--------------------------+               +----------------------------------------+
|      SHOOTER CLIENT      |               |             SPOTTER CLIENT             |
|                          |               |                                        |
| - FiredMan EH            |   sbt_pair    | - ACE Interaction ("Become Spotter")   |
| - Projectile Sampling    | ------------> | - Optics Detection (ADS in binos/scope)|
| - 50 Hz Per-Frame Handler|   sbt_chunk   | - Draw3D Mission Event Handler         |
| - HitPart Impact Hook    | ------------> | - Catmull-Rom Spline Interpolation     |
|                          |  sbt_impact   | - Volumetric Billboard Ribbon Render   |
|                          | ------------> | - drawIcon3D Impact Distance Marker    |
+--------------------------+               +----------------------------------------+
```

## 2. Bullet Trace

```
1. TRIGGER PULL (Shooter)
   └─> fnc_onFired checks: sbt_enabled, valid spotter, distance <= 15m, spotter ADS ready.
   └─> Verifies ammo is BulletCore and initial speed >= 350 m/s.

2. IMPACT HOOK (Shooter)
   └─> Attaches HitPart EH to the live bullet entity to capture exact ASL impact point.

3. SAMPLING LOOP (Shooter)
   └─> Enqueues bullet into sbt_trackedQueue.
   └─> 50 Hz Per-Frame Handler (0.02s interval) records getPosASL every 2m+ of flight.
   └─> Batches points and transmits sbt_traceChunk every 50ms via CBA target event.

4. RECEIVE & SPLINE BAKE (Spotter)
   └─> fnc_receiveTrace converts ASL coordinates to AGL and aligns timestamps.
   └─> Evaluates Catmull-Rom cubic splines across incoming control points using precomputed matrix weights.
   └─> Updates active trace buffer (enforces sbt_maxTraces).

5. TERMINAL IMPACT (Shooter -> Spotter)
   └─> Bullet impacts or despawns. Shooter sends final sbt_traceImpact packet.
   └─> Spotter records terminal AGL impact coordinates and impact mission time.

6. DRAW3D RENDERING (Spotter)
   └─> fnc_draw3D runs every rendered frame while ADS.
   └─> Frustum culls segments behind the camera plane.
   └─> Draws center core and expanding volumetric ribbons drifting with wind.
   └─> Draws 3D dot icon and target distance reading ("842m") at the impact point.

7. EXPIRATION & CLEANUP (Spotter)
   └─> Vapor wake dissipates over sbt_vaporLifetime (default 0.85s).
   └─> Impact icon fades over sbt_impactDuration (default 2.5s).
   └─> Trace tuple is deleted from sbt_activeTraces and sbt_traceIndexMap.
```

---

## 3. Codebase File Structure

| File | Purpose |
| --- | --- |
| `addons/main/config.cpp` | CfgPatches definition, required addons (CBA, ACE), and XEH hooks. |
| `addons/main/script_component.hpp` | Component definition macros (`PREFIX sbt`, `COMPONENT main`). |
| `addons/main/script_macros.hpp` | Macro helpers (`PREP`, debug logs, version string builders). |
| `addons/main/script_version.hpp` | Semantic version numbers (Major, Minor, Patch, Build). |
| `addons/main/XEH_preStart.sqf` | Pre-compilation hook for functions during game start. |
| `addons/main/XEH_preInit.sqf` | Initializes global caches, math weights, and includes settings. |
| `addons/main/XEH_postInit.sqf` | Client-only setup, target event handlers, optics switch listeners. |
| `addons/main/XEH_PREP.hpp` | Function registration list compiled via CBA_fnc_compileFunction. |
| `addons/main/initSettings.inc.sqf` | CBA Addon Options menu registration for all user settings. |
| `addons/main/functions/fnc_becomeSpotter.sqf` | Pairs player to a target shooter unit via ACE interact. |
| `addons/main/functions/fnc_stopSpotting.sqf` | Unpairs player, clears variables, and removes Draw3D. |
| `addons/main/functions/fnc_handlePairRequest.sqf` | Executed on shooter; attaches FiredMan EH and saves spotter. |
| `addons/main/functions/fnc_handleUnpair.sqf` | Executed on shooter; detaches FiredMan EH and clears spotter. |
| `addons/main/functions/fnc_checkOptics.sqf` | Verifies ADS through binos/spotting scope; manages Draw3D EH. |
| `addons/main/functions/fnc_initInteractions.sqf` | Registers ACE actions ("Become Spotter" and "Stop Spotting"). |
| `addons/main/functions/fnc_onFired.sqf` | Shooter FiredMan handler; tracks bullets and streams chunks. |
| `addons/main/functions/fnc_receiveTrace.sqf` | Spotter packet receiver; calculates Catmull-Rom spline curves. |
| `addons/main/functions/fnc_draw3D.sqf` | Per-frame renderer for vapor ribbons and impact distance icons. |
| `addons/main/functions/fnc_parseClassList.sqf` | Parses comma-separated class strings into fast lookup HashMaps. |

---

## 4. Network Protocol and Events

All network communication uses `CBA_fnc_targetEvent`. Data is sent directly to the partner client without broadcasting to other clients or the server.

### `sbt_pair`
- **Target**: Shooter unit
- **Payload**: `[spotter (Object), isReady (Boolean)]`
- **Action**: Shooter stores spotter in `player setVariable ["sbt_spotter", spotter, true]` and attaches `FiredMan` EH.

### `sbt_unpair`
- **Target**: Shooter or Spotter unit
- **Payload**: `[sender (Object)]`
- **Action**: Removes `FiredMan` EH and clears tracking variables.

### `sbt_spotterReady`
- **Target**: Shooter unit
- **Payload**: `[spotter (Object), isReady (Boolean)]`
- **Action**: Updates `spotter setVariable ["sbt_ready", isReady]` on the shooter machine. When `isReady` is false, the shooter ignores all fired rounds.

### `sbt_traceChunk`
- **Target**: Spotter unit
- **Payload**: `[traceKey (String), points (Array), meta (Array)]`
- **Points Format**: `[[posASL, flightTimeSeconds], ...]`
- **Meta Format**: `[muzzleVelocityMps, velocityVector]` on initial chunk; `[]` on subsequent chunks.

### `sbt_traceImpact`
- **Target**: Spotter unit
- **Payload**: `[traceKey (String), points (Array), meta (Array)]`
- **Action**: Marks the trace as impacted, bakes final spline endpoint, and stores impact coordinates for `drawIcon3D`.

---

## 5. Active Trace Data Structure

Each active bullet trace on the spotter machine is stored as a 12-element array inside `sbt_activeTraces` and indexed by `sbt_traceIndexMap`:

```sqf
_trace = [
    _traceKey,          // 0: String   - Unique shot identifier (e.g. "1")
    _posArr,            // 1: Array    - Interpolated spline points in AGL [[x,y,z], ...]
    _impacted,          // 2: Boolean  - True once terminal impact packet is received
    _localStart,        // 3: Number   - Local CBA_missionTime when shot was fired
    _rawAGL,            // 4: Array    - Raw received control points [[posAGL, time], ...]
    _bakedCursor,       // 5: Number   - Next spline control point index to bake
    _renderCursor,      // 6: Number   - First non-expired segment index for Draw3D
    _timeArr,           // 7: Array    - Interpolated timestamps matching _posArr
    _velEst,            // 8: Array    - Instantaneous estimated velocity vector
    _dragFactor,        // 9: Number   - Estimated drag coefficient for dead reckoning
    _impactPosAGL,      // 10: Array   - Terminal impact position [x,y,z] in AGL
    _impactTime         // 11: Number  - Local CBA_missionTime when impact occurred
];
```
