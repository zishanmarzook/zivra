# ZIVRA — Roblox Shooter

Multiplayer arena shooter prototype in Roblox Luau. Features a lobby, 1v1 and 2v2 queues, friend parties, and a zombie survival mode.

## Quick start (no plugins)

1. Open a new **Baseplate** in Roblox Studio.
2. In **Explorer > ServerScriptService**, insert a **Script** named `Main`, then paste the contents of [`src/server/Main.server.luau`](src/server/Main.server.luau).
3. In **StarterPlayer > StarterPlayerScripts**, insert a **LocalScript** named `Main`, then paste the contents of [`src/client/Main.client.luau`](src/client/Main.client.luau).
4. Press **Play** to try Zombie Survival alone. Use **Test > Server & Clients** to launch two or more clients for 1v1 and 2v2. A four-player test is needed for 2v2.

The code creates temporary blockout arenas and a basic menu at runtime. Replace the temporary visuals later. Server must be running for the LocalScript to work.

## Optional sync

The `default.project.json` file supports [Rojo](https://rojo.space/) synchronization as an optional alternative to copying scripts.

## Status

This is a first playable prototype, not a production-ready published experience. You must test multiplayer networking, spawn handling, and the gameplay feel in Roblox Studio before publishing.
