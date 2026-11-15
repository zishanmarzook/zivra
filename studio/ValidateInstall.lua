-- Run in Studio's SERVER Command Bar during Play. Read-only structural smoke test.
local shared=game:GetService("ReplicatedStorage"):FindFirstChild("ZIVRA")
assert(shared,"Missing ReplicatedStorage.ZIVRA")
local server=game:GetService("ServerScriptService"):FindFirstChild("ZIVRA_Server")
assert(server,"Missing server")
local W=require(shared.Weapons)
assert(#W.List==47,"Registry count")
assert(shared:FindFirstChild("Request") and shared:FindFirstChild("Feedback"),"Server did not start: inspect Output errors")
assert(workspace:FindFirstChild("ZIVRA_Runtime"),"Runtime world missing")
local C=require(server.Combat)
for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
 local s=C.States[p]; assert(s,"Profile still loading for "..p.Name)
 for slot,id in ipairs(s.loadout) do assert(W.ById[id].slot==slot,"Invalid slot") end
 assert(p.PlayerGui:FindFirstChild("ZIVRA_UI"),"Client UI missing for "..p.Name)
end
print("ZIVRA structural smoke test passed. This does not replace the multiplayer/touch checklist.")
