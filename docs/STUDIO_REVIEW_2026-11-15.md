# Connected Studio review — 15 November 2026

Target: ZIVRA place `121932020544473`, universe `10776573114`, explicitly confirmed by the owner. Work uses `codex/zivra-combat-range` and draft PR #1. No live publication or merge is authorized.

## Preservation and source reconciliation

The existing place was ahead of GitHub. All 48 live scripts were exported before edits. Existing headquarters, map/round, movement, and M4 systems were preserved, along with `Workspace.ZIVRA_Corridor` and `Workspace.ZIVRAMapPreview`. The three primary installation roots each existed exactly once. No installer was rerun. The refreshed `src/` includes pre-existing Studio integration changes; `studio-snapshot/` preserves the other scripts. This snapshot does not include geometry, remotes, Tools, or other non-script instances and is not a standalone reconstruction of the full place.

Initial recovery copies of the four initially edited roots are in `ServerStorage.ZIVRA_Recovery_20261115`. The client-root backup includes its UI child. A full pre-edit script export also remains in the local task workspace.

## Changes made during this review

- Shared graphite/navy, muted cyan, amber, and red tokens across combat and headquarters; removed purple card fills.
- Headquarters starts with the main menu closed, uses clearer Play/menu navigation, links the real combat settings panel, and accurately describes range practice and starter equipment.
- Repaired garbled close, hit-confirmation, and feedback text.
- Combat menu buttons have a 44-pixel minimum height; compact loadout layout also activates on narrow portrait screens.
- Combat menus temporarily hide native touch controls and backpack, then restore their previous state.
- Mode changes and respawn close combat menus, preventing permanently hidden controls after death.
- Headquarters passes gamepad input through during combat. Y opens loadout and B closes it; hardware focus needs a physical-controller check.
- Windows tooling reads source and compiler output as UTF-8.

Modified live objects: `ReplicatedStorage.ZIVRA.Theme`, `ReplicatedStorage.ZIVRAHQ.UIComponents`, `StarterPlayer.StarterPlayerScripts.ZIVRAHQClient`, `StarterPlayer.StarterPlayerScripts.ZIVRA_Client`, and its `UI` child. Four additional text-only encoding repairs affect `ZIVRA.MatchAdapter`, `ZIVRAMapServices.RoundService`, `ZIVRAWeaponClient`, and `ZIVRALobbyUI.LobbyClient`; their originals were also checkpointed. No map geometry was edited.

## Actual Studio checks

Passed through the running game's client/server remotes: range entry and return, rifle ammo use and reload, same-frame fire cadence rejection, handgun equip/fire/ammo, switch cancelling rifle reload, settings sensitivity update, and restoration of owned rifle/handgun/knife loadout on lobby return. A rifle hit reduced a target from 200 to 170 health. Walking into knife reach and striking reduced a target from 200 to 165 health.

Death/respawn returned to Lobby at 100 health, closed the menu, restored native touch/backpack controls, and left exactly one `ZIVRA_UI`. Injected Y/B input opened and closed the combat loadout. iPhone 17 Pro landscape settings and portrait loadout/settings were captured and inspected. A minimum touch-target and native-control overlap pass was applied. The final saved place version is 39; no live experience was published. All 48 source scripts match the installed Studio sources after newline normalization. Studio was restored to its default viewport and Edit mode. Final Output checks contained no runtime errors.

The existing automated suites pass 310 registry/policy, 32 mocked combat lifecycle, and 16 mocked persistence assertions. Compilation covers both active source and preserved script snapshots. These tests do not establish real DataStore, network, or multiplayer behavior.

## ForgeGUI ledger and remaining work

MCP capabilities and generation-history reads succeeded. No ZIVRA asset matches were returned from MCP or website history searches. A personal Roblox publishing connection for creator `3516965067` was active and eligible for Image, Model, and Audio publishing. This does not establish experience ownership or asset loading.

Owner-confirmed available balance: 10,000 credits. Independently verified balance: unavailable. Paid generation cost quote: unavailable in the connected tool schemas. Jobs started: none. Credits spent by this review: 0. No artwork or Roblox asset IDs were created. Paid generations remain paused under the owner's explicit rule requiring a bounded cost. Public `.com` pages did not expose a current numerical generation price; pricing found on other domains was not assumed to apply.

The requested Forge sample, icon and promotional artwork remain incomplete. Screenshots showed UI but no rendered 3D scene, so world/viewmodel appearance was not visually approved. Physical mobile multitouch, full controller focus, multiplayer damage/team restrictions, real persistence/reconnect, sound/animation completeness, and performance remain unverified. Existing weapon models are procedural blockouts and custom weapon audio remains absent.

## Updating and rollback

The connected place was updated directly and verified after restart. For another copy of the same audited baseline, `studio/UpdateAuditedUI.lua` selectively updates the nine edited scripts in Edit mode. It refuses other place IDs, missing objects, or changed source fingerprints; it accepts an already-applied result. It clones recovery copies before writing and never installs duplicate systems. Rebuild it with `python scripts/build_ui_update.py` from the repository root. Fingerprints detect routine source drift, not adversarial modification.

Do not use the generic installer to overwrite this place. The original three-root Rojo mapping does not deploy the headquarters snapshot. Reconcile future edits before syncing. Roll back an edited source from the matching recovery object's `OriginalPath`, keeping existing maps and unrelated systems intact. Stop/restart Play after source changes. Saving creates a place version; publishing the live experience is a separate owner action.

## Subsequent Forge sample pass

The owner explicitly authorized one unquoted generation after the earlier pricing blocker. The website independently showed 10,000 credits before and 7,826 afterward, an observed sample charge of 2,174. One original emblem was generated, published as approved Roblox Image `129565854362406`, installed in the headquarters header, and verified loaded on desktop and phone layout captures. Place version 40 contains this addition. No additional paid generation was started; the game icon and promotional artwork are still incomplete. This supersedes the earlier zero-generation ledger above; see `docs/FORGE_ASSETS.md` for exact IDs and evidence.

## Combat feedback continuation — saved version 43

Headquarters now starts with the menu closed after the loading flow, including hiding the shell during initialization. The Forge emblem still loads. Server snapshots expose a reloading flag derived from the reload epoch and active busy time; cancelling by switching/menu/reset naturally invalidates it. The HUD shows RELOADING and a native progress bar, with READYING for other short busy states. Phone health/ammo/reload status is grouped in the left status area above the native joystick; measured bounds confirmed no reload-bar overlap with the joystick or six custom action controls in iPhone 17 Pro landscape.

A short native directional arrow uses the existing authoritative Hurt message's source position. Its display and direction were verified using a synthetic server feedback message with no actual damage applied. This is UI integration evidence, not a multiplayer damage test.

Live checks passed startup closed state, server-backed reload feedback, clearing reload on switch, invalid fire payload rejection, lobby return, and clean Output. The source/snapshot compiler passes 48 scripts. Assertion totals are now 310 policy + 35 combat lifecycle + 16 persistence = 361; the three new checks cover reload-state start, completion and switch cancellation. Default viewport and Edit mode were restored. Recovery: `ServerStorage.ZIVRA_PreCombatFeedback_1794757756` contains the original edited roots, including the UI child.

No paid Forge calls were made in this continuation; last verified remaining balance remains 7,826 credits. Physical multitouch, full portrait combat layout, real controller focus, multiplayer, persistence and 3D visual approval remain outside these checks. The selective updater now also includes the Combat module; it still targets the audited original baseline or an already-applied final source and refuses intermediate/custom changes rather than overwriting them.


## Headquarters artwork pass — 16 November 2026

Owner explicitly approved spending up to all 7,826 remaining credits on additional unpriced ZIVRA artwork/audio, releasing the previous reserve. One thumbnail generation completed:

- Job `2bd0efc7-91e8-4bcf-9306-5ba246dc98d8`, request `zivra-hq-keyart-20261115-01`, one provider execution.
- Artifact `mcp-artifact:2bd0efc7-91e8-4bcf-9306-5ba246dc98d8:0`.
- Roblox Image `78032110481735`, publication `c5919eb1-aceb-46d6-a471-af7c982af83e`, ready and moderation approved, creator `3516965067`.
- Website balance decreased from 7,826 to 5,822: observed charge 2,004 credits. Total observed spend including emblem: 4,178 credits.
- Audio request `zivra-rifle-shot-20261115-01` was refused with `paid_generation_required` and an upgrade URL. No audio job ID or output was created. Per Forge connector instructions, all further paid calls stopped. Website still showed 5,822 credits; do not describe that balance as zero or claim all credits were consumed.

Integrated art into the headquarters Play page as a cropped background with a native text shade. Match controls stay above artwork, including on phone. Added minimum 44px headquarters buttons, respected ReducedMotion for menu entry, and hid/restored native backpack/touch UI around the headquarters menu. A watcher handles touch GUI creation/enabling while the menu is open.

Validation: Roblox PreloadAsync Success; ImageLabel.IsLoaded true. Desktop and iPhone 17 Pro landscape screenshots inspected. On the normal phone menu flow: menu open -> touch/backpack false; menu close -> both true. All inspected headquarters TextButtons were at least 44px high. Changing simulated device during an open menu showed inconsistent restoration and is not an approved use-case; physical touch remains untested. All 48 source/snapshot scripts compile; 361 existing assertions pass. One AssistantCommand diagnostic error occurred while looking for PlayerModule; no game-script errors observed in that playtest.

Stopped Play and restored the default simulator viewport. Saved cloud place version 47; live experience not published. Recovery folder: `ServerStorage.ZIVRA_PreHQArtwork_1794758946`. Existing maps and core combat logic unchanged in this pass.
