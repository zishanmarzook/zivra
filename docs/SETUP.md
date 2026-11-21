> Existing audited place (121932020544473): use the selective update described in `docs/STUDIO_REVIEW_2026-11-15.md`. Do not rerun the fresh installer or replace the place. The current place includes headquarters, map, movement and M4 systems outside the original three-root mapping. Their scripts are preserved in `studio-snapshot/`; their geometry and existing remotes remain Studio-owned.

# Install and synchronize ZIVRA

## Easiest route: one Command Bar paste

Use `studio/InstallZivra.lua` in your existing place's Command Bar while **not playing**. Enable Command Bar from Studio's View/Window menu if it is hidden. Copy the complete Raw file, including its final lines. The script contains the source code; it does not download or execute remote code.

The installer adds exactly these code roots:

| Location | Installed root |
|---|---|
| ReplicatedStorage | ZIVRA (four shared ModuleScripts) |
| ServerScriptService | ZIVRA_Server (server Script with six child ModuleScripts) |
| StarterPlayer → StarterPlayerScripts | ZIVRA_Client (LocalScript with three child ModuleScripts) |

It refuses to overwrite any existing root with these names. It does not remove the house, spawn, maps, or other scripts. Do not repeatedly paste it to update an installation: use Rojo below. If you accidentally installed two older combat systems under different names, stop and inspect them before enabling this one.

During Play, the server creates `ReplicatedStorage.ZIVRA.Request`, `.Feedback`, and `Workspace.ZIVRA_Runtime`. The range is centered at `(0,1000,0)` and the arena at `(600,1000,0)`. These areas are runtime-generated and disappear when Play stops; modify `World.luau` to edit the generator. Kiosks are placed relative to `ZIVRA_Spawn`. The original house remains an editable Studio model.

## Profiles in Studio

The installer sets `Workspace.ZIVRA_OfflineProfiles = true`. If DataStore access fails **in Studio only**, a temporary starter profile is used and the HUD says **UNSAVED**. It is never written to DataStore. This lets you test without publishing or changing security settings.

For persistence tests, use a separate test experience, enable Studio API access in its settings, and run this once in Edit-mode Command Bar:

```lua
workspace:SetAttribute("ZIVRA_OfflineProfiles", false)
```

Stop and restart Play. A failed profile load now refuses entry instead of substituting defaults. Live servers always refuse unsafe failed loads regardless of the attribute. Do not enable Studio API access against your production save data just to run tests.

Schema version: `1`. DataStore: `ZIVRA_Profiles_v1`. Keys: `u:<UserId>`. Profiles auto-save every 60 seconds and release their session lock on departure/shutdown. Stale locks expire after 180 seconds. A reconnect after a crashed server may need to wait for expiry. Normal retries are bounded to three attempts. UpdateAsync/session-lock behavior still needs testing in Roblox's real service.

## Rojo workflow for ongoing edits

Rojo was not present in the original repository. `default.project.json` is now an additive mapping that deliberately omits Workspace and Lighting. Existing unknown siblings under mapped services are preserved. Do not add Workspace to this file unless you intentionally decide to synchronize your map.

1. Install the official **Rojo 7.4.4 CLI** and its matching Studio plugin. `aftman.toml` pins the CLI if you already use Aftman; Aftman is optional.
2. Download/clone this implementation branch to your own Mac or Windows computer. Open a terminal in its repository folder.
3. Run:

   ```sh
   rojo serve default.project.json
   ```

4. Open the **existing place** in Studio. In the Rojo plugin, connect to `localhost:34872`.
5. Review the synchronization preview. It should map only the three code roots above. If the plugin offers to delete unrelated content, cancel and inspect the configuration.
6. Sync, save, and Play. Local source edits then update the mapped scripts. Stop and restart Play after server/module changes so cached requires do not hide updates.

An installation made with the Command Bar uses the same hierarchy, so it can subsequently be managed with this mapping. Preserve your own edits by copying them back into `src/` before syncing.

To regenerate the one-paste installer after source changes:

```sh
python scripts/build_installer.py
```

To verify the mapping without modifying a Studio place:

```sh
mkdir -p work
rojo build default.project.json --output work/validation.rbxlx
```

This generated place is a test artifact, not a replacement for your existing place.

## Connecting Studio to a future local Codex session

This cloud/Linux session cannot run or inspect your Studio instance. Use Roblox Studio plus ChatGPT desktop or Codex on Mac/Windows. Official setup: https://create.roblox.com/docs/studio/setup.

With ZIVRA open, go to **Assistant → … → Settings → MCP Servers**, enable **Studio as MCP server**, and turn on **Quick Connect → ChatGPT (codex)** if available. Open a fresh local Codex thread and request Studio validation of this branch. This is optional for importing the code; the installer and Rojo paths work independently of MCP.
