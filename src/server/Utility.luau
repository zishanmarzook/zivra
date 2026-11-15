local Players=game:GetService("Players")
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Utility={}
local C
function Utility.init(combat) C=combat end
local function now() return os.clock() end
local function deployment(owner,position,d)
	local count=0
	for _,x in ipairs(C.Deployments) do if x.owner==owner and x.def.id==d.id then count+=1 end end
	if count>=(d.limit or 2) or #C.Deployments>=64 then return nil end
	local p=Instance.new("Part"); p.Name="ZIVRA_"..d.id; p.Size=d.kind=="pad" and Vector3.new(5,0.4,5) or Vector3.new(1.4,0.5,1.4)
	p.Position=position+Vector3.new(0,p.Size.Y/2,0); p.Anchored=true; p.CanCollide=false
	p.Color=d.kind=="pad" and Color3.fromRGB(0,189,255) or Color3.fromRGB(162,43,255); p.Material=Enum.Material.Neon; p.Parent=C.World.Folder
	local x={owner=owner,part=p,position=position,def=d,expires=now()+(d.lifetime or 30),armed=now()+1,mode=C.States[owner].mode,nextTick=0,used={}}
	table.insert(C.Deployments,x); return x
end
function Utility.warp(player,dir,distance,cooldown,useMarker)
	local s=C.States[player]; local _,_,root,head=C.alive(player)
	if not root or now()<(s.cooldowns.warp or 0) then return false end
	local destination=useMarker and s.marker and (s.markerUntil or 0)>now() and s.marker or root.Position+dir*distance
	local delta=destination-root.Position
	if delta.Magnitude>distance+2 then return false end
	local p=C.params(player)
	-- Swept character volume prevents passing through walls, thin geometry and narrow gaps.
	local hit=workspace:Blockcast(root.CFrame,Vector3.new(3,5,3),delta,p)
	if hit then return false end
	local ground=workspace:Raycast(destination+Vector3.new(0,2,0),Vector3.new(0,-12,0),p)
	if not ground or ground.Normal.Y<0.6 then return false end
	destination=Vector3.new(destination.X,ground.Position.Y+3,destination.Z)
	local overlap=OverlapParams.new(); overlap.FilterType=Enum.RaycastFilterType.Exclude; overlap.FilterDescendantsInstances={player.Character}
	for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(destination),Vector3.new(3,4.5,3),overlap)) do if part.CanCollide then return false end end
	if not C.World.inBounds(destination,s.mode) or not C.line(root.Position,destination,nil,player) then return false end
	C.fx("warp",{position=root.Position,finish=destination}); player.Character:PivotTo(CFrame.new(destination)*root.CFrame.Rotation)
	root.AssemblyLinearVelocity=Vector3.zero; s.lastPosition=destination; s.movementWindow={position=destination,time=now()}; s.cooldowns.warp=now()+cooldown; s.marker=nil
	return true
end
function Utility.zone(owner,position,d)
	local x=deployment(owner,position,d)
	if not x then return end
	x.part.Transparency=1; x.part.CanQuery=false
	if d.kind=="smoke" then
		-- Server replicated geometry gives every client the same opaque obstruction, even Low VFX.
		local cloud=Instance.new("Part"); cloud.Name="SmokeVolume"; cloud.Shape=Enum.PartType.Ball
		cloud.Size=Vector3.new(d.radius*2,d.radius*1.2,d.radius*2); cloud.Position=position+Vector3.new(0,d.radius*0.45,0)
		cloud.Anchored=true; cloud.CanCollide=false; cloud.CanQuery=false; cloud.Transparency=0.12; cloud.Color=Color3.fromRGB(100,105,112)
		cloud.Parent=x.part
	end
	C.fx(d.kind,{position=position,radius=d.radius,duration=d.lifetime})
end
function Utility.detonate(player)
	for i=#C.Deployments,1,-1 do
		local x=C.Deployments[i]
		if not x.cancelled and x.owner==player and x.def.kind=="satchel" and now()>=x.armed then
			C.explode(player,x.position+Vector3.new(0,0.6,0),x.def); x.part:Destroy(); table.remove(C.Deployments,i)
		end
	end
end
function Utility.activate(player,dir)
	local s=C.States[player]; local alive,h,root,head=C.alive(player)
	if not alive or not s or s.menu or s.mode=="Lobby" or now()<s.busy then return end
	local d=Weapons.ById[s.loadout[4]]
	if now()<(s.cooldowns[d.id] or 0) or (s.charges[d.id] or 0)<=0 then return end
	local accepted=false
	if d.kind=="heal" then
		if h.Health>=h.MaxHealth then return end
		accepted=true; s.epoch+=1; local epoch=s.epoch; local started=now(); s.busy=started+d.windup
		C.send(player,"Healing",{duration=d.windup})
		task.delay(d.windup,function()
			if C.States[player]~=s or s.epoch~=epoch or not C.alive(player) then return end
			if s.lastHit>started then C.snapshot(player,"Healing interrupted by damage"); return end
			h.Health=math.min(h.MaxHealth,h.Health+d.heal); C.fx("heal",{position=root.Position}); C.snapshot(player,"Healed")
		end)
	elseif d.kind=="grapple" then
		if s.grapple then s.grapple=nil; return end
		local hit=workspace:Raycast(head.Position,dir*d.range,C.params(player))
		if hit and hit.Instance.Anchored and hit.Instance.CanCollide and not hit.Instance:FindFirstAncestorOfClass("Accessory") then
			s.grapple={position=hit.Position+hit.Normal*2,untilTime=now()+d.duration}; accepted=true
			C.fx("grapple",{position=root.Position,finish=hit.Position,owner=player.UserId,duration=d.duration})
		end
	elseif d.kind=="warp" then accepted=Utility.warp(player,dir,d.range,d.cooldown)
	elseif d.kind=="mine" or d.kind=="satchel" or d.kind=="pad" then
		local aim=dir
		if d.kind=="pad" then aim=Vector3.new(dir.X,-1,dir.Z).Unit end
		local hit=workspace:Raycast(head.Position,aim*d.range,C.params(player))
		if hit and hit.Instance.Anchored and hit.Instance.CanCollide and hit.Normal.Y>0.6 and C.World.inBounds(hit.Position+Vector3.new(0,3,0),s.mode) then
			accepted=deployment(player,hit.Position,d)~=nil
		end
	elseif d.kind=="freeze" then
		local hit=workspace:Raycast(head.Position,dir*d.range,C.params(player)); accepted=true
		C.fx("freeze",{position=head.Position,finish=hit and hit.Position or head.Position+dir*d.range})
		if hit then local m=hit.Instance:FindFirstAncestorOfClass("Model"); if m then C.damage(player,m,d.damage,hit.Instance,head.Position,d) end end
	elseif d.kind=="horn" then
		accepted=true
		for other,os in pairs(C.States) do
			local ok,_,r=C.alive(other)
			local ally=other==player or (player.Team and not player.Neutral and other.Team==player.Team)
			if ok and ally and os.mode==s.mode and os.match==s.match and (r.Position-root.Position).Magnitude<d.range then os.buffUntil=now()+d.duration end
		end
		C.fx("horn",{position=root.Position,radius=d.range})
	elseif d.speed then accepted=C.Projectiles.launch(player,head.Position,(dir+Vector3.new(0,0.15,0)).Unit,d,1) end
	if accepted then
		s.charges[d.id]-=1; s.cooldowns[d.id]=now()+d.cooldown; s.busy=math.max(s.busy,now()+0.3)
		C.send(player,"Fired",{id=d.id}); C.snapshot(player)
	else C.snapshot(player,"No valid surface or destination") end
end
function Utility.step()
	local time=now()
	for i=#C.Deployments,1,-1 do
		local x=C.Deployments[i]; local s=C.States[x.owner]; local remove=x.cancelled or not s or s.mode~=x.mode or time>=x.expires or not C.alive(x.owner)
		if not remove and time>=x.armed and time>=x.nextTick then
			x.nextTick=time+0.25
			if x.def.kind=="mine" then
				for _,model in ipairs(C.targets(x.owner)) do
					local r=model:FindFirstChild("HumanoidRootPart")
					if r and (r.Position-x.position).Magnitude<8 and C.line(x.position+Vector3.new(0,0.8,0),r.Position,model,x.owner) then
						C.explode(x.owner,x.position+Vector3.new(0,0.8,0),x.def); remove=true; break
					end
				end
			elseif x.def.kind=="molotov" then
				for _,model in ipairs(C.targets(x.owner)) do
					local r=model:FindFirstChild("HumanoidRootPart")
					if r and (r.Position-x.position).Magnitude<x.def.radius and C.line(x.position+Vector3.new(0,1,0),r.Position,model,x.owner) then C.damage(x.owner,model,x.def.damage,r,x.position,x.def,true) end
				end
			elseif x.def.kind=="pad" then
				for player,ps in pairs(C.States) do
					local ok,_,r=C.alive(player)
					if ok and ps.mode==s.mode and ps.match==s.match and (r.Position-x.position).Magnitude<5 and time>(x.used[player] or 0) then
						x.used[player]=time+1.5; local v=r.AssemblyLinearVelocity
						r.AssemblyLinearVelocity=Vector3.new(math.clamp(v.X,-30,30),65,math.clamp(v.Z,-30,30)); C.fx("pad",{position=x.position})
					end
				end
			end
		end
		if remove then x.part:Destroy(); table.remove(C.Deployments,i) end
	end
end
return Utility
