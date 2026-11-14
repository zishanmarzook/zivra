# Phase 1 validation

Executed in the connected ZIVRA Studio place in a single-client Play session. Tests used the real weapon request RemoteEvent, server weapon scripts, and a temporary Humanoid dummy outside the lobby. All test geometry, enabled zones, and drivers were removed by cleanup/ending Play. No combat zone is left enabled in Edit mode.

| Check | Observed |
|---|---|
| Initial ammo | 30 |
| Body damage | 24 |
| Head damage | 42 |
| Twelve immediate fire requests | One accepted hit, 24 damage |
| Nonfinite direction | No ammo consumed |
| Solid wall between shooter and target | Zero target damage |
| Reload in progress | Server reported true |
| Fire during reload | No ammo consumed |
| Completed reload | 30 magazine / 116 reserve after four shots |
| Reload then unequip | Cancelled; magazine stayed at 29 |
| Enabled zone overlapping lobby | Zero target damage |
| Weapon HUD | Present, enabled on equip, received ammo state |
| Existing queue | Still running; station reported STEP ONTO PLATFORM |
| Existing camera | First-person mode and camera UI retained |

The initial test harness hit a Studio capability restriction when trying to write script Source from a running server Script; the corrected harness created its drivers through the Studio tool. Client-only attributes also needed an explicit test-only report RemoteEvent to inspect ammo from the server. These harness issues were corrected before the reported ammo results were collected.

Not yet verified: multiple simultaneous real clients, mobile input on a device, visual quality, sustained performance, kill-confirmation UI, same-team damage behavior, latency handling, death/respawn stress cases, reserve exhaustion, and all later-phase features. Automated testing sent real firing requests, but does not establish that manual mouse/touch controls feel correct. No finished-game claim is made.
