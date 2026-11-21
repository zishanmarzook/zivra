# Required Roblox Studio acceptance checks

Selected checks were run in the connected Studio session on 15 November 2026; see `docs/STUDIO_REVIEW_2026-11-15.md` for exact results and remaining gaps. The checklist below is broader than the completed checks. Test a saved copy of your existing place. Keep Output visible. Do not publish this branch as production-ready based on syntax/unit tests alone.

## First boot and core lifecycle

1. Run the installer once in Edit-mode Command Bar. Run it again: it must refuse without deleting or changing existing objects. Confirm `ZIVRA_Lobby` and `ZIVRA_Spawn` remain intact.
2. Play. Confirm one HUD and one weapon model; inspect server Output for require/property errors. Run `studio/ValidateInstall.lua` in the **server** Command Bar during Play after the profile loads.
3. In the lobby, firing must not damage anyone. Click RANGE; confirm the player arrives above the range floor facing the targets.
4. AR: hold fire, count ammo, empty the magazine, reload, try firing while reloading. Switch weapons halfway through reload and wait: the old magazine must not silently refill.
5. Handgun: each click fires once; holding must not auto-fire. Knife: attack a target inside reach, outside reach, and behind a wall. Only genuine, unobstructed hits should count.
6. Medkit: in a two-player duel take damage, use G, then take damage during the two-second use. Healing must be interrupted. Successful healing caps at max health and consumes a charge. Switching cancels its completion.
7. Reset/die during reload, charge, healing, or grappling. No delayed attack/heal should apply after respawn. Ammo/health/state reset only through legitimate round/range/respawn rules.

## Weapon menu and trials

1. Press B or LOADOUT. Verify blur is isolated to `ZIVRA_MenuBlur`; another game's effect must remain unchanged. Mouse can navigate. World firing stops. Closing restores first-person handling.
2. Count 14 Primary, 11 Secondary, 10 Melee, 12 Utility cards plus a Random card per category. Verify all names, current slot models, white selected outline, scrolling and readable labels.
3. Try locked RPG/Bow/Grappler in the range. Confirm ownership is unchanged. Return to lobby and enter a duel: only owned defaults return. Reconnect to verify the locked trial did not persist.
4. Trial Random selects only valid category items and changes choices when alternatives exist. Lobby Random only chooses owned items.
5. Re-select a partly used trial weapon: it must retain its ammo. RESET RANGE may legitimately refill and clear training statistics; it grants no competitive rewards.

## Touch, desktop, gamepad

Use Studio's Device Emulator at **1536×706, 1280×720, 1920×1080, 640×360, and 568×320**. Also check native top bar/insets on an actual phone. Smaller portrait layouts are not acceptance-tested or guaranteed.

- Wide grids show five columns; narrow grids shrink without horizontal overflow.
- Move with the native joystick while holding FIRE and dragging aim. Confirm the same touch is tracked; releasing another finger must not release fire.
- Jump with Roblox's native control while moving/shooting. Confirm custom buttons do not intercept it.
- Exercise reload, crouch, sprint-slide, alternate actions, utility, all four equipment slots, and weapon menus.
- Change button positions and sizes in Settings, save, reconnect, and reset. Try overlapping buttons: the layout editor should reject overlaps.
- Open chat/native menu, alt-tab, die, and open/close weapon menus while holding fire: no stuck trigger or blocked mouse.
- On gamepad, test triggers, bumpers, D-pad slots, menu navigation, sprint and crouch. Preserve native movement/jump.

## Distinct weapon exercise

- Burst: three rounds and inter-burst recovery. Shotgun/Shorty: multiple pellets and strong falloff. Revolver: six-shot high-damage cadence. Uzi/Spray: separate rates/magazines/spread.
- Bow: short/full charge changes damage and speed; release without starting charge cannot fire; switch/alternate cancels. Crossbow/Slingshot/Paintball: visible ballistic travel and surface impacts.
- Minigun: no fire before spinup; barrels animate; overheat stops shots until cooled; changing weapons must not clear heat. Check firing movement penalty.
- RPG/Grenade Launcher: impact or fuse, gravity/bounces as appropriate, bounded falloff, no explosion through walls. Explosions must not hit players in another mode.
- Flamethrower: short cone, fuel, obstruction, finite burn. Permafrost/Freeze Ray: slow expires and has immunity; it must not become indefinite. Distortion must never disable input.
- Gunblade: slash has separate geometry and recovery. Energy rifle: heat. Energy pistols: shared ammo (independent hand animation remains unfinished). Warper: marker only within maximum distance and a clear, grounded destination.
- Ten melee items: compare reach/width/timing; shield reduces frontal hits, does not protect rear, and only partly reduces explosion damage. Chainsaw overheats and stops on release.
- Grappler: valid anchored surfaces, range limit, acceleration/collision and cancel. Jump Pad: limited lifetime and launch velocity. Warpstone: walls, low ceilings, arena bounds, and missing floor must reject unsafe destinations.
- Mine/Satchel: arm delay, owner-only remote detonation, maximum placements and cleanup. Grenade/Molotov/Smoke/Flashbang: fuse/impact/lifetime, LOS, reduced-flash setting, and consistent smoke on Low VFX. Horn affects self/allies only and expires.

## Multiplayer, rewards, persistence

Use Studio **Test → Start Server** with at least two clients (three or four for queue stress).

- Queue or send/accept a duel invitation. Only one pair enters the arena; other players wait. Countdown prevents early fire. Win a genuine duel and check kill/win/currency/task counters on the server.
- Disconnect, reset, forfeit, or wait for timeout: no fake win reward. Invite expiry, target leaving, and repeated invitation/claim requests are handled without duplicate matches or rewards.
- Fire simultaneously, inspect replicated held weapons and effects, and verify matching health changes. Check default team settings and neutral/Friendly Fire behavior.
- Claim a completed task twice: exactly one reward. Reconnect and verify currency/claims/settings/loadout. Range hits and resets must not progress duel tasks.
- Use a separate test experience for real DataStore checks; disable offline fallback. Simulate failed loads and concurrent sessions: no empty starter data may overwrite existing valid data.
- In the client Command Bar during Play, adversarially send unknown IDs, huge/NaN directions, arbitrary damage fields, rapid Fire/Reload/Equip calls, locked equips from Lobby, and shots while dead. Observe server refusal. Never test exploits against another person's game.
- End a round with rockets, mines, fire, and grapples active. Confirm server objects/forces are removed; inspect any lingering short cosmetic effects.

## Performance and art sign-off

Run sustained combat for at least ten minutes on Low/Automatic and High. Watch instance count, active connections, memory, network traffic, and frame time. Confirm effect/projectile/deployment caps hold and that smoke/combat indicators stay readable at Low. No 30/60 FPS target is considered verified until measured on relevant devices.

Capture menu, lobby, range, ADS, and touch HUD frames. Compare them to supplied references once available. Review model silhouettes, spacing, contrast, icon clarity, viewmodel clipping, actual hand animation, accessibility, and licensed audio. Blockout visuals or missing audio are not final acceptance.
