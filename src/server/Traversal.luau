local RunService = game:GetService("RunService")

local Traversal = {}

function Traversal.find(character, root, humanoid, direction, arena)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {arena}
	params.RespectCanCollide = true

	local stance = root.Size.Y * 0.5 + humanoid.HipHeight
	local feet = root.Position - Vector3.yAxis * stance
	local probe = feet + Vector3.yAxis * 0.8
	local face = workspace:Raycast(probe, direction * 4, params)
	if not face then
		face = workspace:Raycast(probe + Vector3.yAxis * 2, direction * 4, params)
	end
	if not face or math.abs(face.Normal.Y) > 0.25 then return nil end

	local ledge = face.Position + direction * 1.5
	local top = workspace:Raycast(Vector3.new(ledge.X, feet.Y + 6.6, ledge.Z), -Vector3.yAxis * 7, params)
	if not top or top.Instance ~= face.Instance or top.Normal.Y < 0.9 then return nil end
	local rise = top.Position.Y - feet.Y
	if rise < 1.15 or rise > 5.8 then return nil end

	local lift = Vector3.new(root.Position.X, top.Position.Y + stance + 0.45, root.Position.Z)
	local front = face.Position + direction * 2
	local across = Vector3.new(front.X, lift.Y, front.Z)
	local kind = "Mantle"
	if rise <= 3.6 then
		local far = face.Position + direction * 5.2
		local floor = workspace:Raycast(Vector3.new(far.X, lift.Y, far.Z), -Vector3.yAxis * (stance + rise + 2.5), params)
		if floor and floor.Instance ~= top.Instance and floor.Normal.Y >= 0.8 and math.abs(floor.Position.Y - feet.Y) < 2 then
			across = Vector3.new(far.X, lift.Y, far.Z)
			kind = "Vault"
		end
	end
	local body = Vector3.new(2.5, 4.1, 2.5)
	local clearance = Vector3.yAxis * 0.6
	local function blocked(from, to)
		local delta = to - from
		return delta.Magnitude > 0.01 and workspace:Blockcast(CFrame.new(from + clearance), body, delta, params)
	end
	-- If the overhead path intersects another solid, native jumping continues.
	if blocked(root.Position, lift) or blocked(lift, across) then return nil end
	return {lift = lift, across = across, kind = kind}
end

function Traversal.start(player, root, path, isActive)
	local character = player.Character
	local begin = root.Position
	local rotation = root.CFrame.Rotation
	local duration = path.kind == "Vault" and 0.33 or 0.42
	root.Anchored = true
	root.AssemblyLinearVelocity = Vector3.zero
	character:SetAttribute("ZIVRATraversing", path.kind)
	task.spawn(function()
		local elapsed = 0
		while elapsed < duration do
			elapsed += RunService.Heartbeat:Wait()
			if player.Character ~= character or not root.Parent or not isActive() then break end
			local progress = math.clamp(elapsed / duration, 0, 1)
			local position
			if progress < 0.45 then
				position = begin:Lerp(path.lift, progress / 0.45)
			else
				position = path.lift:Lerp(path.across, (progress - 0.45) / 0.55)
			end
			root.CFrame = CFrame.new(position) * rotation
		end
		if character.Parent then character:SetAttribute("ZIVRATraversing", nil) end
		if player.Character == character and root.Parent and isActive() then root.Anchored = false end
	end)
end

return Traversal
