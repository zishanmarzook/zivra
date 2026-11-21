local Arena = {HalfWidth = 50, HalfLength = 75}

local tile = Color3.fromRGB(222, 225, 227)
local wall = Color3.fromRGB(235, 237, 238)
local cover = Color3.fromRGB(201, 207, 211)
local deck = Color3.fromRGB(216, 221, 224)
local joint = Color3.fromRGB(190, 199, 205)
local accent = Color3.fromRGB(103, 163, 176)

function Arena.build(parent, origin)
	local model = Instance.new("Model")
	model.Name = "ZIVRA_WhiteObstacleArena"
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	local function part(name, size, frame, color, decoration)
		local item = Instance.new("Part")
		item.Name = name
		item.Size = size
		item.CFrame = CFrame.new(origin) * frame
		item.Anchored = true
		item.Material = Enum.Material.Concrete
		item.Color = color
		if decoration then
			item.CanCollide = false
			item.CanTouch = false
			item.CanQuery = false
			item.CastShadow = false
		end
		item.Parent = model
		return item
	end

	local function box(name, x, z, width, height, length, color, bottom, yaw)
		return part(name, Vector3.new(width, height, length),
			CFrame.new(x, (bottom or 0) + height/2, z) * CFrame.Angles(0, math.rad(yaw or 0), 0), color)
	end

	local function mark(name, x, y, z, width, length, color)
		part(name, Vector3.new(width, 0.025, length), CFrame.new(x, y, z), color, true)
	end

	local function ramp(name, x1, z1, x2, z2, width, startHeight, endHeight)
		local from, to = Vector3.new(x1, startHeight, z1), Vector3.new(x2, endHeight, z2)
		local delta = to - from
		local horizontal = Vector3.new(delta.X, 0, delta.Z)
		local middle = (from + to)/2
		local sloped = CFrame.lookAt(middle, middle + horizontal.Unit)
			* CFrame.Angles(math.atan2(delta.Y, horizontal.Magnitude), 0, 0)
		part(name, Vector3.new(width, 1, delta.Magnitude), sloped * CFrame.new(0, -0.5, 0), deck)
	end

	box("Tiled foundation", 0, 0, 104, 2, 154, tile, -2)
	for x = -40, 40, 10 do mark("Longitudinal joint", x, 0.017, 0, 0.035, 150, joint) end
	for z = -70, 70, 10 do mark("Transverse joint", 0, 0.018, z, 100, 0.035, joint) end
	for _, side in ipairs({-1, 1}) do
		box("Side perimeter", side*51, 0, 2, 23, 154, wall)
		box("End perimeter", 0, side*76, 100, 23, 2, wall)
	end

	-- Upper section: offset platforms and a wedge on the left.
	box("Upper left landing", -35, -54, 15, 7, 14, deck)
	ramp("Upper left incline", -42, -65, -35, -58, 6, 2.1, 7)
	box("Upper left wedge base", -42, -66, 7, 2.1, 5, cover, 0, 18)
	box("Upper middle low step", -9, -51, 12, 3, 7, deck)
	box("Upper middle raised block", 1, -55, 23, 9.5, 9, cover)
	box("Upper right platform", 29, -56, 14, 11.5, 16, cover)
	box("Upper right recessed step", 37, -49, 8, 5.5, 9, deck)
	ramp("Upper right access", 41, -35, 39, -46, 6, 0.1, 5.5)

	-- Upper-middle section: two diagonals frame the exposed crossing.
	ramp("Upper narrow diagonal", -36, -23, -24, -42, 4.5, 0.1, 6.6)
	box("Upper narrow landing", -23, -43, 7, 6.6, 7, cover, 0, -28)
	ramp("Upper broad diagonal", 25, -17, 14, -36, 10, 0.1, 5.5)
	box("Upper broad landing", 13, -38, 11, 5.5, 6, cover, 0, 22)

	-- Central section: tall lateral cover and an elevated square deck.
	box("Central left wall", -30, -4, 8, 15.8, 25, cover, 0, -10)
	box("Central right wall", 30, 5, 8.5, 16.5, 24, cover, 0, 13)
	box("Center canopy", 0, 0, 20, 1.5, 21, deck, 8.7)
	for _, x in ipairs({-7, 7}) do
		box("Canopy pier", x, -7, 3, 8.7, 3, cover)
		box("Canopy pier", x, 7, 3, 8.7, 3, cover)
	end
	box("Center approach step", -14, 10, 8, 3.2, 8, deck)
	box("Center intermediate step", -11, 7, 7, 6.65, 6, cover)
	box("Center opposite step", 13, -11, 7.5, 4.5, 7, deck)
	box("Center opposite landing", 11, -8, 6, 7.4, 5, cover)

	-- Lower-middle section: a wide incline and a narrower ledge on a different heading.
	ramp("Lower broad diagonal", -41, 45, -24, 22, 10, 0.1, 6.1)
	box("Lower broad landing", -23, 20, 12, 6.1, 7, cover, 0, 19)
	ramp("Lower narrow diagonal", 36, 41, 24, 22, 4.5, 0.1, 5.2)
	box("Lower narrow landing", 23, 21, 7, 5.2, 7, cover, 0, -23)
	box("Lower central divider", 8, 26, 5.5, 12.3, 15, cover, 0, -29)
	box("Vault barrier", -8, 38, 10, 2.6, 3, cover)

	-- Lower section: small left pad, horizontal center platform and solid right cover.
	box("Lower left pad", -34, 57, 12, 3.1, 10, deck)
	box("Lower middle platform", 0, 54, 25, 8, 8, cover)
	box("Lower right cover", 31, 51, 13, 13.6, 16, cover)
	box("Lower right access step", 38, 59, 8.5, 4.2, 7, deck)
	for _, side in ipairs({-1, 1}) do
		mark("Spawn panel", 0, 0.022, side*65.5, 9, 0.12, accent)
	end

	model.Parent = parent
	return model
end

return Arena
