# Connected Studio review — 15 November 2026

Target: ZIVRA place `121932020544473`, universe `10776573114`, explicitly confirmed by the owner. Work uses `codex/zivra-combat-range` and draft PR #1. No live publication or merge is authorized.

## Preservation and source reconciliation

The existing place was ahead of GitHub. All 48 live scripts were exported before edits. Existing headquarters, map/round, movement, and M4 systems were preserved, along with `Workspace.ZIVRA_Corridor` and `Workspace.ZIVRAMapPreview`. The three primary installation roots each existed exactly once. No installer was rerun. The refreshed `src/` includes pre-existing Studio integration changes; `studio-snapshot/` preserves the other scripts. This snapshot does not include geometry, remotes, Tools, or other non-script instances and is not a standalone reconstruction of the full place.

Initial recovery copies of the four edited roots are in `ServerStorage.ZIVRA_Recovery_20261115`. The client-root backup includes its UI child. A full pre-edit script export also remains in the local task workspace.

## Changes made during this review

- Shared graphite/navy, muted cyan, amber, and red tokens across combat and headquarters; removed purple card fills.
- Headquarters starts with the main menu closed, uses clearer Play/menu navigation, links the real combat settings panel, and accurately describes range practice and starter equipment.
- Repaired garbled close, hit-confirmation, and feedback text.
- Combat menu buttons have a 44-pixel minimum height; compact loadout layout also activates on narrow portrait screens.
- Combat menus temporarily hide native touch controls and backpack, then restore their previous state.
- Mode changes and respawn close combat menus, preventing permanently hidden controls after death.
- Headquarters passes gamepad input through during combat. Y opens loadout and B closes it; hardware focus needs a physical-controller check.
- Windows tooling reads source and compiler output as UTF-8.

Modified live objects: `ReplicatedStorage.ZIVRA.Theme`, `ReplicatedStorage.ZIVRAHQ.UIComponents`, `StarterPlayer.StarterPlayerScripts.ZIVRAHQClient`, `StarterPlayer.StarterPlayerScripts.ZIVRA_Client`, and its `UI` child. No map geometry was edited.

## Actual Studio checks

Passed through the running game's client/server remotes: range entry and return, rifle ammo use and reload, same-frame fire cadence rejection, handgun equip/fire/ammo, switch cancelling rifle reload, settings sensitivity update, and restoration of owned rifle/handgun/knife loadout on lobby return. A rifle hit reduced a target from 200 to 170 health. Walking into knife reach and striking reduced a target from 200 to 165 health.

Death/respawn returned to Lobby at 100 health, closed the menu, restored native touch/backpack controls, and left exactly one `ZIVRA_UI`. Injected Y/B input opened and closed the combat loadout. iPhone 17 Pro landscape settings and portrait loadout/settings were captured and inspected. A minimum touch-target and native-control overlap pass was applied. Studio was restored to its default viewport and Edit mode. Final Output checks contained no runtime errors.

The existing automated suites pass 310 registry/policy, 32 mocked combat lifecycle, and 16 mocked persistence assertions. Compilation covers both active source and preserved script snapshots. These tests do not establish real DataStore, network, or multiplayer behavior.

## ForgeGUI ledger and remaining work

MCP capabilities and generation-history reads succeeded. No ZIVRA asset matches were returned from MCP or website history searches. A personal Roblox publishing connection for creator `3516965067` was active and eligible for Image, Model, and Audio publishing. This does not establish experience ownership or asset loading.

Owner-confirmed available balance: 10,000 credits. Independently verified balance: unavailable. Paid generation cost quote: unavailable in the connected tool schemas. Jobs started: none. Credits spent by this review: 0. No artwork or Roblox asset IDs were created. Paid generations remain paused under the owner's explicit rule requiring a bounded cost. Public `.com` pages did not expose a current numerical generation price; pricing found on other domains was not assumed to apply.

The requested Forge sample, icon and promotional artwork remain incomplete. Screenshots showed UI but no rendered 3D scene, so world/viewmodel appearance was not visually approved. Physical mobile multitouch, full controller focus, multiplayer damage/team restrictions, real persistence/reconnect, sound/animation completeness, and performance remain unverified. Existing weapon models are procedural blockouts and custom weapon audio remains absent.

## Updating and rollback

The connected place was updated directly and verified after restart. For another copy of the same audited baseline, `studio/UpdateAuditedUI.lua` selectively updates the five edited scripts in Edit mode. It refuses other place IDs, missing objects, or changed source fingerprints; it accepts an already-applied result. It clones recovery copies before writing and never installs duplicate systems. Rebuild it with `python scripts/build_ui_update.py` from the repository root. Fingerprints detect routine source drift, not adversarial modification.

Do not use the generic installer to overwrite this place. The original three-root Rojo mapping does not deploy the headquarters snapshot. Reconcile future edits before syncing. Roll back an edited source from the matching recovery object's `OriginalPath`, keeping existing maps and unrelated systems intact. Stop/restart Play after source changes. Saving creates a place version; publishing the live experience is a separate owner action.
