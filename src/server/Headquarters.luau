local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ZIVRA")
local Models=require(Shared.Models)
local Weapons=require(Shared.Weapons)

local Headquarters={}
local color={
	concrete=Color3.fromRGB(55,59,63),
	floor=Color3.fromRGB(73,77,80),
	graphite=Color3.fromRGB(29,33,36),
	black=Color3.fromRGB(16,20,23),
	metal=Color3.fromRGB(94,103,108),
	ink=Color3.fromRGB(242,245,245),
	cyan=Color3.fromRGB(103,187,201),
	glass=Color3.fromRGB(155,191,199),
	lamp=Color3.fromRGB(223,235,238),
}

function Headquarters.build(parent,origin,onStation)
	local model=Instance.new("Model")
	model.Name="ZIVRA_Headquarters"
	model.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
	local originFrame=CFrame.new(origin)

	local function part(name,x,y,z,sx,sy,sz,tint,material,detail)
		local item=Instance.new("Part")
		item.Name=name
		item.Anchored=true
		item.Size=Vector3.new(sx,sy,sz)
		item.CFrame=originFrame*CFrame.new(x,y,z)
		item.Color=color[tint]
		item.Material=material or Enum.Material.Metal
		item.CanTouch=false
		if detail then
			item.CanCollide=false
			item.CanQuery=false
			item.CastShadow=false
		end
		item.Parent=model
		return item
	end

	local function sign(board,face,text,tint,font)
		local gui=Instance.new("SurfaceGui")
		gui.Name="Sign"
		gui.Face=face
		gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud=40
		gui.MaxDistance=100
		gui.LightInfluence=0
		gui.Parent=board
		local label=Instance.new("TextLabel")
		label.Size=UDim2.fromScale(0.92,0.8)
		label.Position=UDim2.fromScale(0.04,0.1)
		label.BackgroundTransparency=1
		label.Font=font or Enum.Font.GothamBold
		label.TextColor3=color[tint or "ink"]
		label.TextScaled=true
		label.Text=text
		label.Parent=gui
		return label
	end

	local function light(x,y,z,width,depth,range,brightness)
		local fixture=part("Recessed luminaire",x,y,z,width,0.08,depth,"lamp",Enum.Material.Neon,true)
		local beam=Instance.new("SurfaceLight")
		beam.Face=Enum.NormalId.Bottom
		beam.Range=range
		beam.Angle=125
		beam.Brightness=brightness
		beam.Color=color.lamp
		beam.Shadows=false
		beam.Parent=fixture
	end

	part("Foundation",0,-0.8,0,68,1.6,86,"floor",Enum.Material.Concrete)
	part("North bulkhead",0,10,-43,68,20,1.7,"concrete",Enum.Material.Concrete)
	part("South bulkhead",0,10,43,68,20,1.7,"concrete",Enum.Material.Concrete)
	part("Ceiling",0,19.8,0,68,1.5,86,"black")
	for _,side in ipairs({-1,1}) do
		part("Long structural wall",side*34,10,0,1.6,20,86,"concrete",Enum.Material.Concrete)
		part("Lower wall apron",side*33,1.1,0,0.25,2.2,84,"black")
		part("Upper wall register",side*33,14.8,-2,0.5,4.2,82,"graphite")
		part("Floor wayfinding",side*6.5,0.018,17,0.15,0.028,36,"cyan",Enum.Material.SmoothPlastic,true)
		for _,z in ipairs({-35,-12,12,30}) do
			part("Buttress",side*31.5,9.4,z,2.8,18.8,2.2,"graphite")
			part("Buttress cap",side*29.9,9.4,z,0.24,17.6,2.2,"metal")
		end
		for _,z in ipairs({-38,-18,2,22,40}) do
			part("Flush floor joint",side*18.5,0.012,z,24,0.02,0.065,"graphite",Enum.Material.SmoothPlastic,true)
		end
	end
	for _,z in ipairs({-27,0,26}) do
		part("Overhead girder",0,17.9,z,65,1.7,2.7,"graphite")
		light(0,16.99,z,27,0.33,23,1.8)
	end
	for _,x in ipairs({-10,10}) do
		part("Entry jamb",x,5.6,29,1.9,11.2,1.6,"graphite")
		part("Jamb reveal",x,5.7,28.15,0.12,7.2,0.08,"metal",nil,true)
	end
	part("Entry lintel",0,11.1,29,22.2,1.5,1.7,"graphite")
	part("Entry ceiling baffle",0,13.6,35,24,1.3,12,"black")
	light(0,12.9,36,13,0.23,18,1.4)
	local entrance=part("Entrance sign",0,11.1,29.89,15,0.85,0.07,"black",nil,true)
	sign(entrance,Enum.NormalId.Back,"ZIVRA  /  HEADQUARTERS","ink")

	local backdrop=part("Matchmaking backdrop",0,8.1,-40.8,46,13,0.65,"graphite")
	local wordmark=part("ZIVRA wordmark",0,11.45,-40.42,26,4.3,0.08,"graphite",nil,true)
	sign(wordmark,Enum.NormalId.Back,"ZIVRA","ink")
	local banner=part("Mode identification",0,7.7,-40.42,24,1.7,0.08,"black",nil,true)
	sign(banner,Enum.NormalId.Back,"1V1  /  MATCHMAKING","cyan")
	local emblem=Instance.new("SurfaceGui")
	emblem.Face=Enum.NormalId.Back
	emblem.LightInfluence=0
	emblem.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
	emblem.PixelsPerStud=24
	emblem.Parent=backdrop
	local mark=Instance.new("ImageLabel")
	mark.BackgroundTransparency=1
	mark.Size=UDim2.fromScale(0.12,0.43)
	mark.Position=UDim2.fromScale(0.075,0.235)
	mark.Image="rbxassetid://129565854362406"
	mark.ScaleType=Enum.ScaleType.Fit
	mark.Parent=emblem

	part("Station base",0,0.30,-17.5,14,0.60,7,"graphite")
	part("Station housing",0,2.1,-17.5,10.5,3,2.5,"black")
	part("Station top rail",0,3.63,-17.5,10.8,0.12,2.8,"metal")
	local station=part("Queue display",0,2.65,-16.19,9,1.37,0.12,"graphite")
	local status=sign(station,Enum.NormalId.Back,"PLAY 1V1","cyan")
	local prompt=Instance.new("ProximityPrompt")
	prompt.Name="MatchmakingPrompt"
	prompt.ActionText="Open matchmaking"
	prompt.ObjectText="1V1 station"
	prompt.MaxActivationDistance=12
	prompt.RequiresLineOfSight=true
	prompt.Parent=station
	prompt.Triggered:Connect(function(player)
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and (root.Position-station.Position).Magnitude<=14 then onStation(player) end
	end)
	for _,x in ipairs({-21,21}) do
		part("Controlled access housing",x,4.6,-39.45,7,9.2,1.7,"black")
		part("Controlled access leaf",x,4.3,-38.52,5.5,8.4,0.13,"metal")
		local glass=part("Observation inset",x,6.05,-38.42,3,1.7,0.064,"glass",Enum.Material.Glass,true)
		glass.Transparency=0.21
		local access=part("Access identification",x,9.55,-38.43,7,0.75,0.08,"graphite",nil,true)
		sign(access,Enum.NormalId.Back,"AUTHORIZED ACCESS","ink")
	end

	local function display(side,z,id)
		local face=side<0 and Enum.NormalId.Right or Enum.NormalId.Left
		local weapon=Weapons.ById[id]
		part("Armory case",side*32.25,4.9,z,1.35,7.5,8.6,"black")
		part("Armory shelf",side*31.20,2.1,z,2.05,0.18,8.4,"metal")
		part("Armory lintel",side*31.20,8,z,1.85,0.18,8.4,"metal")
		local placa=part("Armory nameplate",side*31.12,2.63,z,0.1,0.77,7.4,"graphite",nil,true)
		sign(placa,face,weapon.name:upper(),"ink")
		local shape=Models.build(weapon,false)
		local extents=shape:GetExtentsSize()
		shape:ScaleTo(math.min(3.5/math.max(extents.Y,0.2),6.7/math.max(extents.Z,0.2),1.38))
		shape:PivotTo(originFrame*CFrame.new(side*31.02,4.85,z)*CFrame.Angles(0,side<0 and 0 or math.pi,0))
		shape.Parent=model
		light(side*30.5,7.81,z,0.34,6.6,7.5,1.15)
	end
	for index,id in ipairs({"assault_rifle","sniper_rifle","shotgun","revolver"}) do display(-1,24-(index-1)*10.25,id) end
	for index,id in ipairs({"handgun","knife","medkit"}) do display(1,24-(index-1)*10.25,id) end
	for _,side in ipairs({-1,1}) do
		local header=part("Armory header",side*32.5,10.2,11,0.09,1.2,24,"graphite",nil,true)
		sign(header,side<0 and Enum.NormalId.Right or Enum.NormalId.Left,"ARMORY","cyan")
	end
	part("Equipment storage",30.7,3.4,-19.1,4.5,6.8,11,"graphite")
	for _,z in ipairs({-22.5,-19,-15.5}) do
		part("Locker vent",28.42,5.2,z,0.05,0.38,1.95,"black",nil,true)
		part("Locker pull",28.36,3.45,z,0.12,0.82,0.18,"metal",nil,true)
	end

	local spawn=Instance.new("SpawnLocation")
	spawn.Name="Arrival"
	spawn.Anchored=true
	spawn.Neutral=true
	spawn.Duration=0
	spawn.Transparency=1
	spawn.CanCollide=false
	spawn.CanTouch=false
	spawn.CanQuery=false
	spawn.Size=Vector3.new(6,0.12,4)
	spawn.CFrame=originFrame*CFrame.new(0,0.12,36)
	spawn.Parent=model
	model.Parent=parent
	return {model=model,spawn=spawn,arrival=originFrame*CFrame.new(0,3.25,36),status=status}
end

return Headquarters
