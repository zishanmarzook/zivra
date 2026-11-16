# ZIVRA ForgeGUI sample — 15 November 2026

- Purpose: one reusable decorative headquarters emblem; graphite metal and cyan, transparent cutout, native text remains separate.
- Authorization: owner explicitly allowed one unquoted generation, then a balance check before more paid work.
- Starting balance, verified on forgegui.com: 10,000 credits.
- Ending balance after the sample, verified after reloading: 7,826 credits.
- Observed charge: 2,174 credits. No further paid jobs authorized or started in this sample pass.
- Generation job: `a1a35325-3d24-4baa-b32d-1546d85fe1c8`.
- Request ID: `zivra-emblem-sample-20261115-01`.
- Result: succeeded, one image, one provider execution attempt.
- Artifact: `mcp-artifact:a1a35325-3d24-4baa-b32d-1546d85fe1c8:0`.
- Delivered dimensions: 1254 × 1254 PNG (the requested target was 1024 × 1024).
- Transparency spot check: corner alpha 0, centre alpha 255.
- Local artwork: `ZIVRA-emblem-sample.png`.
- Roblox image publication: `ad15ec78-4887-4e5f-8e3e-96f5176d9de5`, initially processing. This publishes an image asset, not the live experience.

The credit amount is the observed website balance difference; the generation response did not provide an itemized price. Two rejected input-validation calls preceded the accepted request; the accepted job reports attempt_count 1. No duplicate generation was started.

## Roblox and Studio result

Publication completed: ready, moderation approved. Roblox Image asset ID: `129565854362406`, personal creator `3516965067`.

Integrated into `StarterPlayer.StarterPlayerScripts.ZIVRAHQClient` as `ZIVRAHeadquarters.Header.ZIVRAEmblem`. Header text remains native. Desktop and iPhone 17 Pro landscape screenshots were inspected; the symbol remained proportional and legible. `ContentProvider:PreloadAsync` returned Success and `ImageLabel.IsLoaded` was true. Studio Output was clean. Restored default viewport and Edit mode; saved place version 40. The live experience was not published.

Recovery: `ServerStorage.ZIVRA_Recovery_20261115.ZIVRAHQClient_PreForgeEmblem`. No further generation was started after the 2,174-credit balance decrease. Remaining 7,826 credits includes the untouched 2,000-credit reserve.


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


## Final-allocation audit — 16 November 2026
No paid calls made in this audit: the prior upgrade_url response requires paid calls to remain stopped under the Forge connector instructions. No new icon, thumbnail, or model is claimed. Last verified balance remains 5,822; not freshly verified in this audit. Existing two successful generations confirmed in MCP history.

CI run 43899706465 passed compilation and 361 assertions but failed installer reproducibility. Cause: pathlib path ordering is case-insensitive on Windows and case-sensitive on Linux. Generator now sorts by the case-sensitive filename string on both systems; regenerated installer compiles. This generator was not executed in Studio. Local 48-file compilation and all 361 assertions were rerun successfully during this audit.
