# ZIVRA — Roblox Shooter

We're building this **step by step**, starting with just a small house-style spawn lobby. No weapon or game-mode logic has been added.

## Stage 1: Create the room in Roblox Studio

1. Launch **Roblox Studio** and create a **Baseplate** experience.
2. In Studio, enable **Explorer** and **Command Bar** (look under **View** or **Window**, depending on your Studio layout).
3. Open [studio/CreateRoom.lua](studio/CreateRoom.lua) on GitHub, click **Raw**, then copy all the Lua code.
4. **While NOT in Play mode**, paste it into Studio's **Command Bar** and press **Enter**. This generates a permanent, editable model in `Workspace > ZIVRA_Lobby`.
5. Look inside `ZIVRA_Lobby` to see the floor, walls, open doorway, roof, benches, table, and spawn pad.
6. Disable/delete the default Baseplate SpawnLocation if it competes with `ZIVRA_Spawn` (don't remove the new one).
7. **Save** your Roblox place and click **Play** to test spawning. If your view is blocked by the roof in edit mode, temporarily hide `Roof` using Properties > Transparency or move the camera inside.

### Important

- You run the script once **in Command Bar**, not in ServerScriptService. Generated parts remain editable in Studio.
- Rerunning it will not overwrite an existing `ZIVRA_Lobby`; rename or remove the old model only if you really want a new one.
- GitHub stores the code, but does **not** automatically deploy it to your Roblox game.
- This is a blockout only. The fancy room graphics, UI, friend parties, 1v1, 2v2 and zombie apocalypse come in later stages.

## Next

Walk through the Studio setup with Codex or ChatGPT and confirm the room spawns correctly before adding gameplay.
