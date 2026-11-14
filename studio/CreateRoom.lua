-- ZIVRA: STAGE 1 — SIMPLE HOUSE LOBBY
-- Run this file ONCE in Roblox Studio's Command Bar (in EDIT mode).
-- It creates real editable Parts in Workspace, not runtime-only objects.
-- Intentionally NO shooting, matchmaking, zombies, or UI yet.

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("ZIVRA_Lobby") then
    warn("ZIVRA_Lobby already exists. Keep your edits! Rename or delete it manually to regenerate.")
    return
end

local lobby = Instance.new("Model")
lobby.Name = "ZIVRA_Lobby"
lobby.Parent = Workspace

local function block(name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = lobby
    return p
end

local floorColor = Color3.fromRGB(77, 82, 94)
local wallColor = Color3.fromRGB(140, 146, 158)
local trimColor = Color3.fromRGB(55, 61, 74)

-- 72 x 60 stud room; simple blockout geometry for later design.
block("Floor", Vector3.new(72, 1, 60), Vector3.new(0, 0, 0), floorColor, Enum.Material.Concrete)
block("BackWall", Vector3.new(72, 18, 1), Vector3.new(0, 9.5, -30), wallColor)
block("LeftWall", Vector3.new(1, 18, 60), Vector3.new(-36, 9.5, 0), wallColor)
block("RightWall", Vector3.new(1, 18, 60), Vector3.new(36, 9.5, 0), wallColor)

-- Front wall with a 12-stud-wide doorway (easy to expand later).
block("FrontLeft", Vector3.new(30, 18, 1), Vector3.new(-21, 9.5, 30), wallColor)
block("FrontRight", Vector3.new(30, 18, 1), Vector3.new(21, 9.5, 30), wallColor)
block("DoorHeader", Vector3.new(12, 7, 1), Vector3.new(0, 15, 30), wallColor)
block("Roof", Vector3.new(73, 1, 61), Vector3.new(0, 19, 0), trimColor)

-- A few editable blockout props, not final graphics.
block("FrontStep", Vector3.new(16, 1, 8), Vector3.new(0, 0, 34), floorColor, Enum.Material.Concrete)
block("LeftBench", Vector3.new(16, 2, 5), Vector3.new(-20, 2, -17), trimColor)
block("RightBench", Vector3.new(16, 2, 5), Vector3.new(20, 2, -17), trimColor)
block("CenterTable", Vector3.new(12, 3, 6), Vector3.new(0, 2.5, -14), trimColor)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "ZIVRA_Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 1.25, 9)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(83, 151, 255)
spawn.Material = Enum.Material.Neon
spawn.Parent = lobby

print("ZIVRA lobby created! Expand Workspace > ZIVRA_Lobby to edit the parts.")
print("Save your place (Ctrl+S). Press Play to test spawning in the room.")
