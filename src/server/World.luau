-- Additive runtime practice world. Never clears or edits the existing lobby/map.
local World={Targets={},Origin=Vector3.new(0,1000,0), ArenaOrigin=Vector3.new(600,1000,0), HQOrigin=Vector3.new(0,240,110)}
local Arena=require(script.Parent.BlueprintArena)
local Headquarters=require(script.Parent.Headquarters)
local Config=require(game.ReplicatedStorage.ZIVRA.Config)
local CollectionService=game:GetService("CollectionService")
local function part(parent,name,size,cf,color,material)
	local p=Instance.new("Part")
	p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
	p.Anchored=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
	return p
end
local white=Color3.fromRGB(222,227,232)
local dark=Color3.fromRGB(27,30,39)
local blue=Color3.fromRGB(0,189,255)
local function label(p,text)
	local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=24; gui.Parent=p
	local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=text
	t.TextColor3=Color3.new(1,1,1); t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.Parent=gui
end
local function prompt(p,text,fn)
	local q=Instance.new("ProximityPrompt"); q.ActionText=text; q.ObjectText="ZIVRA"; q.MaxActivationDistance=12; q.RequiresLineOfSight=true; q.Parent=p
	q.Triggered:Connect(function(player)
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and (root.Position-p.Position).Magnitude<=14 then fn(player) end
	end)
end
function World.spawn(side,round)
	local sign=(side+round)%2==0 and 1 or -1
	local position=World.ArenaOrigin+Vector3.new(0,3.4,67*sign)
	return CFrame.lookAt(position,position-Vector3.new(0,0,sign))
end
function World.build(onRange,onLobby,onDuel,onStation)
	assert(not workspace:FindFirstChild("ZIVRA_Runtime"),"Duplicate ZIVRA server startup")
	local folder=Instance.new("Folder"); folder.Name="ZIVRA_Runtime"; folder.Parent=workspace; World.Folder=folder
	World.Arena=Arena.build(folder,World.ArenaOrigin)
	local corridor=workspace:FindFirstChild("ZIVRA_Corridor")
	local spawn=corridor and corridor:FindFirstChild("LobbySpawn") or workspace:FindFirstChild("ZIVRA_Spawn",true)
	World.LobbyCFrame=spawn and spawn.CFrame+Vector3.new(0,4,0) or CFrame.new(0,6,9)
	if Config.Launch1v1 then
		World.Headquarters=Headquarters.build(folder,World.HQOrigin,onStation)
		World.LobbyCFrame=World.Headquarters.arrival
		return
	end
	local range=Instance.new("Model"); range.Name="PracticeRange"; range.Parent=folder
	local o=World.Origin
	part(range,"Floor",Vector3.new(180,2,250),CFrame.new(o),white,Enum.Material.Concrete)
	for _,x in ipairs({-90,90}) do part(range,"Boundary",Vector3.new(2,35,250),CFrame.new(o+Vector3.new(x,17,0)),dark) end
	for _,z in ipairs({-125,125}) do part(range,"Boundary",Vector3.new(180,35,2),CFrame.new(o+Vector3.new(0,17,z)),dark) end
	for _,x in ipairs({-45,0,45}) do
		part(range,"Lane",Vector3.new(0.4,0.05,190),CFrame.new(o+Vector3.new(x,1.03,-10)),blue,Enum.Material.Neon)
		for i,z in ipairs({20,-25,-75}) do
			local target=Instance.new("Model"); target.Name="RangeTarget"; target.Parent=range
			local at=o+Vector3.new(x,4,z)
			local torso=part(target,"Torso",Vector3.new(3,4,1),CFrame.new(at),Color3.fromRGB(230,90,45))
			local head=part(target,"Head",Vector3.new(1.6,1.6,1.2),CFrame.new(at+Vector3.new(0,2.8,0)),white)
			local root=part(target,"HumanoidRootPart",Vector3.new(2,2,1),CFrame.new(at),dark); root.Transparency=1; root.CanCollide=false; root.CanQuery=false
			local h=Instance.new("Humanoid"); h.MaxHealth=200; h.Health=200; h.RequiresNeck=false; h.BreakJointsOnDeath=false; h.Parent=target
			target.PrimaryPart=root; target:SetAttribute("ZIVRA_Target",true); CollectionService:AddTag(target,"ZIVRA_Target")
			World.Targets[target]={base=at,moving=i==2,health=h,parts={torso,head,root}}
			label(torso,string.format("%d STUDS",math.abs(75-z)))
		end
	end
	local exit=part(range,"Return",Vector3.new(14,5,1),CFrame.new(o+Vector3.new(0,5,112)),Color3.fromRGB(8,123,255))
	label(exit,"RETURN TO LOBBY"); prompt(exit,"Return to Lobby",onLobby)
	for i=1,5 do part(range,"MobilityStep",Vector3.new(12,2,12),CFrame.new(o+Vector3.new(72,1+i*2,70-i*18)),dark) end
	local base=World.LobbyCFrame.Position
	local entrance=part(folder,"RangeKiosk",Vector3.new(8,5,1),CFrame.new(base+Vector3.new(12,0,0)),dark)
	label(entrance,"ZIVRA / TRAINING"); prompt(entrance,"Enter Shooting Range",onRange)
	local duel=part(folder,"DuelKiosk",Vector3.new(8,5,1),CFrame.new(base+Vector3.new(-12,0,0)),dark)
	label(duel,"ZIVRA / 1 V 1"); prompt(duel,"Queue / Leave Queue",onDuel)
end
function World.queueStatus(queued,busy)
	local hq=World.Headquarters
	if not hq then return end
	local message=queued>0 and (queued.." IN QUEUE") or busy and "DUEL IN PROGRESS" or "PLAY 1V1"
	if hq.status.Text~=message then hq.status.Text=message end
end
function World.inBounds(pos,mode)
	local o=mode=="Range" and World.Origin or World.ArenaOrigin
	local v=pos-o
	return math.abs(v.X)<(mode=="Range" and 87 or Arena.HalfWidth) and math.abs(v.Z)<(mode=="Range" and 122 or Arena.HalfLength) and v.Y>0 and v.Y<90
end
function World.step(now)
	for model,t in pairs(World.Targets) do
		if t.reset and now>=t.reset then
			t.hp=t.health.MaxHealth; t.health.Health=t.health.MaxHealth; t.reset=nil
		end
		if t.moving then
			local shift=Vector3.new(math.sin(now*0.8)*8,0,0)
			t.parts[1].Position=t.base+shift; t.parts[2].Position=t.base+shift+Vector3.new(0,2.8,0); t.parts[3].Position=t.base+shift
		end
	end
end
return World
