# ZIVRA 1V1 candidate

This candidate targets place `121932020544473` in universe `10776573114`. Its starting point was Studio place version 49 and branch `codex/zivra-combat-range` at `0b7fead`. The locally exported version 49 place is the recovery checkpoint. Six Studio-only presentation changes were reconciled before the duel work.

## Match rules

- Headquarters queues real players in the current server, in arrival order. One duel uses the white obstacle arena at a time.
- After versus, each player has up to 15 seconds to confirm their equipment. Two confirmations open the protected three-second countdown early. A player who does not confirm keeps their existing loadout. The first player to score three rounds wins.
- Eliminations score a round. At 90 seconds, the player with more health wins the round. An equal-health round replays without scoring. Three such draws end the match in a draw.
- Both players must vote for a rematch. Leaving an active duel or disconnecting ends it without a win award.
- The server rebuilds ammunition, charges and equipment at the start of each round, and restores the saved loadout on return to headquarters.

Match timers live in `src/shared/Config.luau`. Weapon values live in `src/shared/Weapons.luau`. At full damage the assault rifle does 17 body damage, the sniper rifle 55 body and 110 head, the shotgun 2.75 per torso pellet and 22 for all eight pellets, the revolver 34 body, the handgun 25 body and the knife 50. The shotgun starts to fall off after 18 studs. The medkit heals 50 after two seconds and has two charges per round.

## Studio integration

The launch uses the population of the existing cloud place. The core Rojo mapping covers `src/` only. The headquarters and R15 movement integration also depends on the corresponding sources in `studio-snapshot/` and the existing Studio instances. Keep both sets synchronized after selective edits. The historical audited UI updater targets its earlier baseline. Its supported input is documented in the November 15 review.

Launch mode removes player access to legacy modes and keeps the existing geometry and legacy source. The reference arena is authored in `src/server/BlueprintArena.luau` as five zones inside a 100 × 150 stud footprint. The arena has standing clearance throughout. It uses client-side lighting changes so the headquarters retains its lighting. Native pixel art in the match loadout uses `src/client/WeaponIcons.luau` with no uploaded image dependency. The sprint and slide use the existing R15 movement controller. Vault and mantle check obstacle height and sweep body clearance on the server. Crouch changes movement speed and pose.

## Headquarters overhaul

The production headquarters is built by `src/server/Headquarters.luau`. The previous corridor stays in the place. The overhaul starts players at the new entrance and uses a single matchmaking panel for both the station and the Play 1V1 button. Queue join and queue cancel are independent, repeatable requests. The station displays the real queue count or an in-progress duel. Weapon racks use the same launch catalog and geometry as the loadout.

The camera can zoom out while players are in headquarters, choosing equipment, or viewing results. Active combat stays locked to first person. The settings screen persists field of view, auto sprint, and reduced motion through the combat profile. Reduced motion suppresses camera kick, viewmodel sway, and landing bob. Gunshots use the existing sound with pitch variants and spatial playback for nearby opponents. Impact effects use the authoritative raycast material and are capped per shot.

The recovery copy preceding this overhaul was exported from the version 59 working place. One server-accepted elimination can score a round. A second damage event processed in the same tick after the score is recorded cannot score again.

Run `python scripts/test.py --tools <luau-directory>` for compile and automated coverage. Run `python scripts/build_installer.py` to regenerate the baseline installer for source consistency.
