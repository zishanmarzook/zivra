# ZIVRA — Roblox shooter

This branch extends the existing house lobby with a server-owned combat system, a 47-item registry, a weapon selection menu, mobile/desktop/gamepad inputs, a practice range, and a basic 1v1 arena. **It is an implementation candidate with original blockout assets, not a finished or Studio-validated shooter.**

The original [`studio/CreateRoom.lua`](studio/CreateRoom.lua) is unchanged. No existing map is replaced. The new runtime creates separate training and arena areas and adds two interaction kiosks beside the existing spawn.

## Start in your existing place

1. Open your **existing ZIVRA place** in Roblox Studio. Stop Play mode and save a backup.
2. Open [`studio/InstallZivra.lua`](studio/InstallZivra.lua), click **Raw**, and copy the entire file.
3. Paste it into Studio's **Command Bar** in **Edit mode**, then press Enter. The installer checks all three destination names before adding anything and refuses a duplicate installation.
4. Save the place, then press **Play**. Click **RANGE** or use the training kiosk. Press **B** to select equipment. Try Assault Rifle, Handgun, Knife, and Medkit first.
5. Follow [`docs/STUDIO_TESTS.md`](docs/STUDIO_TESTS.md), especially the two-player and mobile checks. If Output reports an error, preserve the error and its script/line number.

If the house has never been created, first run the original `studio/CreateRoom.lua` once in Edit-mode Command Bar. Do not create a new empty place to install this work.

**GitHub does not deploy to Roblox.** The installer must run in Studio, or you can use the documented [Rojo workflow](docs/SETUP.md). No live experience was published by this change.

## Controls

| Action | Desktop | Gamepad | Mobile |
|---|---|---|---|
| Fire / charge | Left mouse | Right trigger | Hold FIRE |
| Aim / alternate / cancel | Right mouse | Left trigger | ALT |
| Reload | R | X | RELOAD |
| Utility | G | Right bumper | UTILITY |
| Equipment slots | 1–4 | D-pad | Four-slot bar |
| Sprint | Shift | Left stick click | SPRINT toggle |
| Crouch / sprint-slide | C / Ctrl | B | CROUCH |
| Loadout | B | Y | LOADOUT |
| Inspect | F | Left bumper | — |
| Jump / movement | Native Roblox | Native Roblox | Native joystick / jump |

## What's actually included

- 14 primary, 11 secondary, 10 melee, and 12 utility definitions, with different behavior families. Only Assault Rifle, Handgun, Knife, and Medkit are permanently owned by default. All 47 can be tried in the range.
- Server validation of ammunition, ownership, cadence, reload/equip state, attack geometry, mode, cooldowns, and explosive damage. Client messages cannot specify damage or rewards.
- Temporary range loadouts, resettable target practice, moving targets, basic statistics, and a return path to the lobby.
- Responsive category/card UI with original procedural ViewportFrame previews; settings, editable touch controls, genuine daily progress, duel invitations and a queue.
- Versioned DataStore profiles with retries and session locks. Explicit offline Studio fallback never writes to a real profile.
- Reproducible offline Studio installer and additive Rojo mapping.

## Current limits

All models/environment assets are blockouts, animations are procedural, and audio asset IDs are intentionally empty until licensed/original audio is supplied. Several advanced mechanics and visual details from the brief still need further work. Only one 1v1 duel can use the arena at a time. There is no competitive/ranked mode, purchasing system, battle pass, or nonstarter unlock economy.

See the [stage-by-stage implementation report](docs/IMPLEMENTATION.md) for exact scope, missing features, tests, and next milestones. No Studio, touch-device, multiplayer, screenshot, or frame-rate validation has been claimed.

## Developer checks

Install the official [Luau CLI](https://github.com/luau-lang/luau/releases) and [Rojo 7.4.4](https://github.com/rojo-rbx/rojo/releases/tag/v7.4.4), then run:

```sh
python scripts/test.py
python scripts/build_installer.py
rojo build default.project.json --output work/validation.rbxlx
```

`work/validation.rbxlx` is only a build check. Do **not** replace your existing place with it. The tests include mocked engine services; Roblox runtime checks remain necessary.
