# ZIVRA: Phase 1 M4

This package adds the first functional M4 prototype to the existing ZIVRA place. It does not replace the lobby, queue scripts, camera toggle, or lobby UI. The model is a block-built prototype, not a finished realistic weapon. There are no sound IDs, uploaded animations, ADS, dedicated viewmodel, other weapons, sprint, or inspect in this phase.

## Already installed in the connected place

The assistant installs and runs checks directly in Studio. Save your place after reviewing. Publishing is a separate action. Stop after this phase and confirm the basic controls feel right before starting Phase 2.

## Install manually or reinstall

1. Open your existing ZIVRA place and stop Play.
2. Save a backup copy.
3. Open `Install-M4.luau`, copy the entire file, then paste it into Studio's **Command Bar** and press Enter. Use Studio's View menu or UI search to find Command Bar. Do not paste into a normal Script.
4. Check Explorer for the placement below.
5. Press Play and equip **slot 1**. Hold left-click to fire; release to stop. Press **R** or click **RELOAD** to reload. On mobile use **FIRE** and **RELOAD**, alongside default Roblox movement controls.
6. The weapon HUD appears only while the M4 is equipped. All damage is disabled outside enabled combat zones; the lobby is protected even if a zone overlaps it.
7. Stop Play and save the place after reviewing.

Reinstall only in Edit mode. The installer checks its five root names for ownership conflicts before replacing them. Its previous roots move to `ServerStorage > ZIVRAWeaponBackup_<timestamp>`. Reinstall resets weapon config to the file defaults, so copy custom settings first. Do not enable scripts in an archived backup. The shared combat-zone folder is preserved.

## Exact script placement

| Source file | Studio location |
|---|---|
| WeaponConfig.luau | ReplicatedStorage > ZIVRAWeapons > WeaponConfig (ModuleScript) |
| WeaponValidation.luau | ServerScriptService > ZIVRAWeapons > WeaponValidation (ModuleScript) |
| DamageService.luau | ServerScriptService > ZIVRAWeapons > DamageService (ModuleScript) |
| WeaponServer.luau | ServerScriptService > ZIVRAWeapons > WeaponServer (Script) |
| WeaponClient.luau | StarterPlayer > StarterPlayerScripts > ZIVRAWeaponClient (LocalScript) |

The installer also creates `ReplicatedStorage > ZIVRAWeapons > WeaponRemotes` with `Request`, `State`, and `Effects` RemoteEvents; `StarterGui > ZIVRAWeaponHUD`; `StarterPack > ZIVRA_M4`; and an empty `Workspace > ZIVRACombatZones` folder. HUD children are generated locally at runtime. `InstallerHeader` and `InstallerFooter` are build fragments; use the complete `Install-M4.luau` file for installation.

## Settings

Edit `WeaponConfig`: magazine 30, reserve 120, body damage 24, head multiplier 1.75, fire interval 0.1 seconds, reload 2.2 seconds, range 600 studs. Reserve ammo resets on respawn and decreases during completed reloads. Reload cancels on unequip or death. No reserve pickups are included. The M4 is the only accepted weapon ID in this phase; adding another weapon later requires extending validation and inventory selection as well as config.

The server controls ammo, reload completion, spread, raycast origins, damage values, and firing cadence. It rejects nonfinite vectors, invalid directions, distant camera origins, shots from a muzzle through a wall, and malformed actions. A per-player token bucket limits request processing. This is a foundation, not a guarantee against all cheating: future combat work must include movement validation and lag-aware aim review.

## Testing damage manually without changing the lobby

Only do this in a saved test copy or a temporary Play session. No combat map is installed.

1. Outside the corridor (for example around X=1000), create a small anchored floor and a target rig using Studio's rig-building tool.
2. Insert a Part under `Workspace > ZIVRACombatZones`. Set Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false, Transparency=1. Size it to contain both shooter and target. Add a **Boolean** attribute named `Enabled` and set it to true.
3. Move your character and target into that zone. Remove any temporary spawn ForceField from the target, or wait for it to expire. A Humanoid and HumanoidRootPart are required on a target.
4. Shoot the torso and head. Expect 24 and 42 damage. A kill confirmation requires a lethal server-accepted hit.
5. Place a solid wall between shooter and target. Expect no damage through the wall.
6. Empty the magazine, reload, then check magazine and reserve. Start a reload and unequip: it should cancel.
7. For multiplayer, start a local server with two clients. Verify both clients see tracers, hits reduce only the intended player's health, respawning resets ammo, and teammates are protected when FriendlyFire=false and both players have the same non-neutral team.
8. Test with both players in the lobby: health must stay unchanged. Check that queue entry, leaving, and camera switching still work.
9. Use mobile emulation to check button reach and layout. Real-device tests are still required.
10. Remove temporary test geometry and combat zones afterward. Leave the zone folder empty until an actual combat area is ready.

## Next phases

Phase 2 replaces the prototype presentation with viewmodel arms, procedural equip/idle/fire/reload animation, sway, and a proper camera integration. Phase 3 adds AK-47, MP5, Desert Eagle, and AWP. Later phases add ADS, recoil, scoped zoom, permitted audio, richer impact particles, advanced HUD, optimization, and multiplayer/mobile QA. No audio asset IDs have been invented.

## Repository

This package is installed directly in Studio and is also saved under `studio/weapons/phase1` on the `feature/m4-phase1` GitHub branch. GitHub changes do not automatically deploy to Studio. Use the complete `Install-M4.luau` file from that branch in Command Bar if reinstalling. The package does not assume Rojo is configured. The existing root README and room script are preserved.
