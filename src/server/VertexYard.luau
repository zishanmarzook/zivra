local Yard = {}

local graphite = Color3.fromRGB(37, 44, 52)
local navy = Color3.fromRGB(38, 54, 66)
local concrete = Color3.fromRGB(100, 109, 113)
local titanium = Color3.fromRGB(142, 153, 154)
local amber = Color3.fromRGB(182, 123, 62)
local cyan = Color3.fromRGB(101, 195, 204)

function Yard.build(parent, origin)
	local arena = Instance.new("Model")
	arena.Name = "VertexYard"
	arena.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

	local function block(name, x, y, z, width, height, depth, color, material, trim, angle)
		local item = Instance.new("Part")
		item.Name = name
		item.Anchored = true
		item.Size = Vector3.new(width, height, depth)
		item.CFrame = CFrame.new(origin + Vector3.new(x, y, z)) * CFrame.Angles(angle or 0, 0, 0)
		item.Color = color
		item.Material = material or Enum.Material.Metal
		if trim then
			item.CanCollide = false
			item.CanTouch = false
			item.CanQuery = false
			item.CastShadow = false
		end
		item.Parent = arena
		return item
	end

	block("Foundry slab", 0, 0, 0, 128, 2, 144, graphite, Enum.Material.Concrete)
	for _, x in ipairs({-63, 63}) do
		block("Side retaining wall", x, 11, 0, 2, 22, 144, navy)
		block("Wall coping", x, 22, 0, 2.4, 0.6, 144, titanium)
		for z = -60, 60, 20 do
			block("Wall buttress", x + (x < 0 and 1.2 or -1.2), 9, z, 1.4, 16, 2, graphite)
		end
	end

	for _, sign in ipairs({-1, 1}) do
		local side = sign == 1 and "North" or "South"
		block(side .. " bulkhead", 0, 15, 71 * sign, 128, 30, 2, navy)
		block("Spawn sightline baffle", 0, 5.5, 52 * sign, 29, 9, 3.5, concrete, Enum.Material.Concrete)
		block("Baffle cap", 0, 10.1, 52 * sign, 29.2, 0.4, 3.7, graphite, nil, true)
		block("Protected staging pad", 0, 1.06, 62 * sign, 22, 0.12, 10, navy, Enum.Material.DiamondPlate, true)
		for _, x in ipairs({-13, 13}) do
			block("Spawn guide", x, 1.03, 62 * sign, 0.32, 0.05, 10, cyan, Enum.Material.Neon, true)
		end

		block("Loading lane cover", -24, 2.45, 36 * sign, 11, 2.9, 3, concrete, Enum.Material.Concrete)
		block("Climbable approach", -45, 2.5, 37 * sign, 13, 3, 12, navy, Enum.Material.DiamondPlate)
		block("Raised service platform", -47, 4, 21 * sign, 15, 6, 13, graphite, Enum.Material.Concrete)
		block("Service deck edge", -39.6, 7.03, 21 * sign, 0.22, 0.08, 12.8, cyan, Enum.Material.Neon, true)
		block("Service cover", -52, 8.55, 22 * sign, 2, 3.1, 6, navy)
		block("Jump-route landing", -43, 5.25, 7 * sign, 12, 1.5, 8, navy, Enum.Material.DiamondPlate)
		block("Jump-route support", -43, 2.75, 7 * sign, 3, 3.5, 3, graphite)

		block("Approach pier", 7 * sign, 5.25, 24 * sign, 9, 8.5, 5.5, concrete, Enum.Material.Concrete)
		block("Center ramp", -7 * sign, 2.75, 14 * sign, 10, 0.65, 14.5, navy, Enum.Material.DiamondPlate, -sign * math.atan(3.5 / 14))
		block("Flank low wall", 22, 2.45, 35 * sign, 12, 2.9, 3, concrete, Enum.Material.Concrete)
		block("Freight container", 42, 5.3, 29 * sign, 16, 8.6, 19, amber)
		for offset = -7, 7, 3.5 do
			block("Freight rib", 33.9, 5.2, 29 * sign + offset, 0.25, 8.1, 0.28, graphite, nil, true)
		end
		block("Freight access step", 43, 2.6, 44 * sign, 10, 3.2, 9, concrete, Enum.Material.Concrete)
		block("Service climb", 48, 4.2, 44 * sign, 6, 6.4, 9, navy)
		block("Passage entrance cover", 51, 3.8, 15 * sign, 4, 5.6, 7, graphite)
	end

	block("Transfer deck", 0, 3.35, 0, 24, 2.3, 14, navy, Enum.Material.DiamondPlate)
	block("Transfer core", 0, 8.35, 0, 6, 7.7, 6, graphite)
	for _, x in ipairs({-2.9, 2.9}) do
		block("Core inspection strip", x, 9.4, 0, 0.25, 4.2, 2.2, amber, Enum.Material.Neon, true)
	end
	local sign = block("Vertex Yard sign", 0, 12.85, 0, 17, 1.7, 1.4, navy)
	for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
		local surface = Instance.new("SurfaceGui")
		surface.Face = face
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 35
		surface.Parent = sign
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.TextColor3 = cyan
		text.TextScaled = true
		text.Font = Enum.Font.GothamBold
		text.Text = "V E R T E X   Y A R D"
		text.Parent = surface
	end

	block("West crossover", -25, 2.5, 0, 10, 3, 10, concrete, Enum.Material.Concrete)
	block("Flank passage deck", 42, 8.35, 0, 23, 1.1, 20, navy, Enum.Material.DiamondPlate)
	block("Passage inner wall", 31, 4.5, 0, 2, 7, 20, graphite)
	block("Passage outer wall", 53, 4.5, 0, 2, 7, 20, graphite)
	block("Upper flank cover", 49, 10.65, -3, 3, 3.5, 6, concrete, Enum.Material.Concrete)
	block("Upper flank cover", 49, 10.65, 3, 3, 3.5, 6, concrete, Enum.Material.Concrete)
	block("Upper flank access", 25, 3, 0, 7, 4, 10, concrete, Enum.Material.Concrete)
	block("Upper flank step", 28, 4.8, 0, 5, 1, 7, navy)
	block("Upper flank step", 31, 6.55, 0, 4, 1, 7, navy)
	for _, z in ipairs({-9.9, 9.9}) do
		block("Passage lintel light", 42, 7.78, z, 13, 0.15, 0.23, cyan, Enum.Material.Neon, true)
	end
	arena.Parent = parent
	return arena
end

return Yard
