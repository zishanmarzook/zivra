local Players=game:GetService("Players")
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Rules=require(game.ReplicatedStorage.ZIVRA.Rules)
local Held=require(script.Parent.HeldModels)
local Combat={States={},Shots={},Deployments={}}
local function clock() return os.clock() end
function Combat.init(remote,world,profiles)
	Combat.Remote=remote; Combat.World=world; Combat.Profiles=profiles
end
function Combat.humanoid(player)
	local c=player.Character
	return c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart"),c and c:FindFirstChild("Head")
end
function Combat.send(player,kind,data) Combat.Remote:FireClient(player,kind,data) end
function Combat.fx(kind,data)
	for player in pairs(Combat.States) do
		local _,root=Combat.humanoid(player)
		if root and data.position and ((root.Position-data.position).Magnitude<350 or data.finish and (root.Position-data.finish).Magnitude<350) then
			Combat.Remote:FireClient(player,"Effect",{kind=kind,data=data})
		end
	end
end
function Combat.snapshot(player,message)
	local s=Combat.States[player]; if not s then return end
	local p=s.profile
	Combat.send(player,"State",{mode=s.mode,loadout=s.loadout,owned=p.owned,slot=s.slot,ammo=s.ammo,
		reserve=s.reserve,charges=s.charges,heat=s.heat,busy=math.max(0,s.busy-clock()),cooldowns=s.cooldowns,
		currency=p.currency,daily=Combat.Profiles.daily(p),settings=p.settings,stats=s.rangeStats,
		message=message,queued=s.queued,serverTime=clock(),offline=s.offline})
end
function Combat.add(player,profile,offline)
	Combat.States[player]={profile=profile,mode="Lobby",loadout=table.clone(profile.loadout),slot=1,
		ammo={},reserve={},charges={},heat=0,busy=0,nextShot=0,epoch=0,cooldowns={},bucket={},menu=false,
		rangeStats={shots=0,hits=0,damage=0},lastHit=0,offline=offline,deployments={}}
end
function Combat.alive(player)
	local h,r,head=Combat.humanoid(player)
	return h and h.Health>0 and r and head,h,r,head
end
function Combat.reset(player)
	local s=Combat.States[player]; if not s then return end
	Combat.cleanup(player)
	s.epoch+=1; s.busy=clock()+0.3; s.nextShot=0; s.heat=0; s.overheated=false; s.slowUntil=0; s.slowImmune=0
	s.burnUntil=0; s.buffUntil=0; s.pendingElimination=false; s.eliminated=false; s.trigger=nil; s.blocking=false; s.menu=false; s.crouch=false; s.sprint=false; s.slideUntil=0
	s.ammo={}; s.reserve={}; s.charges={}; s.cooldowns={}
	for _,id in ipairs(s.loadout) do local d=Weapons.ById[id]; s.ammo[id]=d.magazine; s.reserve[id]=d.reserve; s.charges[id]=d.charges end
	local _,h,r=Combat.alive(player)
	if h then h.Health=h.MaxHealth end
	if r then s.lastPosition=r.Position; s.movementWindow={position=r.Position,time=clock()} end
	Held.equip(player,s.loadout[s.slot])
	Combat.snapshot(player)
end
function Combat.cleanup(player)
	-- Mark cancellation instead of shrinking arrays during an impact callback.
	-- A lethal hit may end a round inside Projectiles.step/Utility.step.
	for _,shot in ipairs(Combat.Shots) do if shot.owner==player then shot.cancelled=true end end
	for i=#Combat.Deployments,1,-1 do
		local x=Combat.Deployments[i]
		if x.owner==player then x.cancelled=true; if x.part then x.part:Destroy() end end
	end
	local s=Combat.States[player]
	if s then s.grapple=nil; s.marker=nil end
end
function Combat.transition(player,mode,cf)
	local s=Combat.States[player]; if not s then return end
	s.mode=mode; s.loadout=table.clone(s.profile.loadout); s.slot=1; s.queued=false
	if mode=="Range" then s.rangeStats={shots=0,hits=0,damage=0,started=clock()} end
	local _,h,r=Combat.alive(player)
	if r then player.Character:PivotTo(cf); r.AssemblyLinearVelocity=Vector3.zero; s.lastPosition=cf.Position end
	Combat.reset(player)
end
function Combat.equip(player,id)
	local s=Combat.States[player]; local d=Weapons.ById[id]
	if not s or not d or not Rules.allowed(d,s.profile.owned,s.mode) then return end
	if s.mode=="Duel" and s.loadout[d.slot]~=id then return end
	if s.loadout[d.slot]~=id then
		s.loadout[d.slot]=id
		-- Preserve per-item ammo: selecting the same or another trial never refills it.
		if s.ammo[id]==nil then s.ammo[id]=d.magazine; s.reserve[id]=d.reserve; s.charges[id]=d.charges end
		if s.mode=="Lobby" then s.profile.loadout[d.slot]=id end
	end
	s.slot=d.slot; s.epoch+=1; s.busy=clock()+d.equip; s.trigger=nil; s.blocking=false; s.grapple=nil
	-- Heat belongs to the state conservatively: switching cannot clear overheating.
	Held.equip(player,d.id)
	Combat.snapshot(player,"Equipped "..d.name)
end
function Combat.params(player)
	local p=RaycastParams.new(); p.FilterType=Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances=player.Character and {player.Character} or {}; p.IgnoreWater=true
	return p
end
function Combat.direction(value)
	if typeof(value)~="Vector3" or not Rules.finite(value.X) or not Rules.finite(value.Y) or not Rules.finite(value.Z) then return nil end
	if value.Magnitude<0.9 or value.Magnitude>1.1 then return nil end
	return value.Unit
end
function Combat.line(from,to,model,owner)
	local delta=to-from
	if delta.Magnitude<0.05 then return true end
	local hit=workspace:Raycast(from,delta,Combat.params(owner))
	return not hit or (model and hit.Instance:IsDescendantOf(model))
end
function Combat.canDamage(owner,model)
	local s=Combat.States[owner]; if not s then return false end
	if model:GetAttribute("ZIVRA_Target") then return s.mode=="Range" end
	local victim=Players:GetPlayerFromCharacter(model)
	local other=victim and Combat.States[victim]
	return victim~=owner and s.mode=="Duel" and other and other.mode=="Duel" and s.match and s.match==other.match
		and (owner.Team==nil or owner.Team~=victim.Team or owner.Neutral or victim.Neutral)
end
function Combat.damage(owner,model,amount,hitpart,from,def,secondary)
	if not Combat.canDamage(owner,model) then return end
	local h=model:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then return end
	if model:FindFirstChildOfClass("ForceField") then return end
	local s=Combat.States[owner]; local victim=Players:GetPlayerFromCharacter(model); local vs=victim and Combat.States[victim]
	local root=model:FindFirstChild("HumanoidRootPart")
	local headshot=hitpart and hitpart.Name=="Head"
	if headshot then amount*=def.headshot or 1 end
	if vs and vs.blocking and root and from and (from-root.Position).Magnitude>0.1 then
		if root.CFrame.LookVector:Dot((from-root.Position).Unit)>0.45 then
			amount*=def.radius and 0.7 or 0.25
			Combat.fx("shield",{position=root.Position})
		end
	end
	local applied=math.min(amount,h.Health)
	local target=Combat.World.Targets[model]
	if target then
		if target.reset then return end
		-- Keep training Humanoids alive; Roblox's Dead state cannot be revived by setting Health.
		local remaining=(target.hp or h.MaxHealth)-amount
		target.hp=math.max(0,remaining); h.Health=math.max(1,target.hp)
		if remaining<=0 then target.reset=clock()+1.5 end
		s.rangeStats.hits+=secondary and 0 or 1; s.rangeStats.damage+=amount
	else
		-- Mark before TakeDamage: Died may run synchronously under Immediate signal behavior.
		if vs and amount>=h.Health then vs.pendingElimination=true end
		h:TakeDamage(amount)
	end
	Combat.send(owner,"Hit",{damage=applied,headshot=headshot,target=target~=nil,position=hitpart and hitpart.Position or (root and root.Position)})
	if vs then
		vs.lastHit=clock(); Combat.send(victim,"Hurt",{from=from,damage=applied})
		if not secondary then
			if def.slow and clock()>(vs.slowImmune or 0) then vs.slowUntil=clock()+1.5; vs.slowScale=def.slow; vs.slowImmune=clock()+4 end
			if def.burn then vs.burnUntil=clock()+def.burn; vs.burnOwner=owner; vs.burnDef=def end
			if def.distort then Combat.send(victim,"Distort",{duration=def.distort}) end
		end
		if h.Health<=0 and not vs.eliminated then
			vs.eliminated=true
			local daily=Combat.Profiles.daily(s.profile); daily.kills+=1; s.profile.stats.kills+=1
			s.profile.currency+=10; Combat.snapshot(owner,"Elimination +10")
			if Combat.onElimination then Combat.onElimination(owner,victim) end
		end
	end
end
function Combat.targets(owner)
	local list={}
	local s=Combat.States[owner]; if not s then return list end
	if s.mode=="Range" then for model in pairs(Combat.World.Targets) do table.insert(list,model) end
	else for _,p in ipairs(Players:GetPlayers()) do if p.Character and Combat.canDamage(owner,p.Character) then table.insert(list,p.Character) end end end
	return list
end
function Combat.explode(owner,position,def)
	Combat.fx("explosion",{position=position,radius=def.radius or 10})
	for _,model in ipairs(Combat.targets(owner)) do
		local root=model:FindFirstChild("HumanoidRootPart")
		if root then
			local dist=(root.Position-position).Magnitude
			if dist<def.radius and Combat.line(position,root.Position,model,owner) then
				Combat.damage(owner,model,Rules.splash(def.damage,dist,def.radius),root,position,def)
			end
		end
	end
end
function Combat.reload(player)
	local s=Combat.States[player]; if not s then return end
	local d=Weapons.ById[s.loadout[s.slot]]
	if not Combat.alive(player) or s.menu or s.mode=="Lobby" or not d.magazine or clock()<s.busy or s.ammo[d.id]>=d.magazine or s.reserve[d.id]<=0 then return end
	s.epoch+=1; local epoch=s.epoch; s.busy=clock()+d.reload; s.trigger=nil; s.blocking=false
	Combat.send(player,"Reload",{duration=d.reload}); Combat.snapshot(player)
	task.delay(d.reload,function()
		if Combat.States[player]~=s or s.epoch~=epoch or not Combat.alive(player) then return end
		local amount=math.min(d.magazine-s.ammo[d.id],s.reserve[d.id]); s.ammo[d.id]+=amount; s.reserve[d.id]-=amount
		Combat.snapshot(player)
	end)
end
function Combat.melee(player,dir,def)
	local s=Combat.States[player]; local epoch=s.epoch
	task.delay(def.windup or 0.16,function()
		if Combat.States[player]~=s or s.epoch~=epoch or s.menu or not Combat.alive(player) then return end
		local _,_,root,head=Combat.alive(player)
		local range=def.meleeRange or def.range
		local overlap=OverlapParams.new(); overlap.FilterType=Enum.RaycastFilterType.Exclude; overlap.FilterDescendantsInstances={player.Character}
		local cf=CFrame.lookAt(head.Position,head.Position+dir)*CFrame.new(0,-0.5,-range/2)
		local parts=workspace:GetPartBoundsInBox(cf,Vector3.new(def.width or 4,5,range),overlap)
		local seen={}
		for _,p in ipairs(parts) do
			local model=p:FindFirstAncestorOfClass("Model")
			if model and not seen[model] and model:FindFirstChildOfClass("Humanoid") and (p.Position-head.Position).Magnitude<=range+2 then
				seen[model]=true
				if Combat.line(head.Position,p.Position,model,player) then Combat.damage(player,model,def.slash or def.damage,p,root.Position,def) end
			end
		end
	end)
end
local rng=Random.new()
function Combat.fire(player,dir,release)
	local s=Combat.States[player]; if not s or not dir then return end
	local d=Weapons.ById[s.loadout[s.slot]]; local now=clock()
	local alive,h,root,head=Combat.alive(player)
	local allowed=Rules.attack({alive=alive,menu=s.menu,mode=s.mode,busy=s.busy,nextShot=s.nextShot,overheated=s.overheated,ammo=s.ammo[d.id] or 0},d,now)
	if not allowed or s.blocking or s.grapple then return end
	if d.slot==4 then Combat.Utility.activate(player,dir); return end
	if d.kind=="charge" and (not release or not s.trigger) then return end
	if d.spinup and (not s.trigger or now-s.trigger<d.spinup) then return end
	local charge=d.charge and math.clamp((now-(s.trigger or now))/d.charge,0,1) or 1
	if d.kind=="charge" then s.trigger=nil end
	s.nextShot=now+d.interval
	if d.kind=="burst" then
		s.burstCount=(s.burstCount or 0)+1
		if s.burstCount>=3 then s.nextShot+=d.burstPause; s.burstCount=0 end
	end
	if d.magazine then s.ammo[d.id]-=1 end
	s.heat=math.min(1,s.heat+(d.heatPerShot or 0)); if s.heat>=1 then s.overheated=true end
	s.lastShot=now; s.rangeStats.shots+=1
	Combat.send(player,"Fired",{id=d.id,charge=charge})
	if d.kind=="melee" then Combat.melee(player,dir,d)
	elseif d.kind=="flame" then
		for _,model in ipairs(Combat.targets(player)) do
			local r=model:FindFirstChild("HumanoidRootPart")
			if r then local delta=r.Position-head.Position
				if delta.Magnitude<d.range and delta.Magnitude>0.05 and dir:Dot(delta.Unit)>d.cone and Combat.line(head.Position,r.Position,model,player) then Combat.damage(player,model,d.damage,r,head.Position,d) end
			end
		end
		Combat.fx("flame",{position=head.Position,finish=head.Position+dir*d.range})
	elseif d.speed then
		Combat.Projectiles.launch(player,head.Position,dir,d,charge)
	else
		local movement=h.MoveDirection.Magnitude*0.8+(h.FloorMaterial==Enum.Material.Air and 2 or 0)
		s.bloom=math.min((s.bloom or 0)+0.15,d.bloom or 1)
		local spread=math.rad(d.spread+movement+(s.bloom or 0))
		for _=1,d.pellets or 1 do
			local frame=CFrame.lookAt(Vector3.zero,dir)
			local radius=math.sqrt(rng:NextNumber())*spread; local angle=rng:NextNumber()*math.pi*2
			local direction=(frame*CFrame.Angles(math.sin(angle)*radius,math.cos(angle)*radius,0)).LookVector
			local hit=workspace:Raycast(head.Position,direction*d.range,Combat.params(player))
			local finish=hit and hit.Position or head.Position+direction*d.range
			Combat.fx("shot",{position=head.Position,finish=finish,id=d.id,owner=player.UserId})
			if hit then
				local model=hit.Instance:FindFirstAncestorOfClass("Model")
				if model then Combat.damage(player,model,d.damage*Rules.falloff(d,(finish-head.Position).Magnitude),hit.Instance,head.Position,d) end
			end
		end
	end
	Combat.snapshot(player)
end
function Combat.trigger(player,on)
	local s=Combat.States[player]; if not s then return end
	if on then
		if not s.trigger and Combat.alive(player) and not s.menu and clock()>=s.busy then s.trigger=clock() end
	else s.trigger=nil end
end
function Combat.alternate(player,dir)
	local s=Combat.States[player]; if not s or not Combat.alive(player) or s.mode=="Lobby" or s.menu or clock()<s.busy then return end
	local d=Weapons.ById[s.loadout[s.slot]]
	if d.slash and clock()>=s.nextShot then
		s.nextShot=clock()+0.8; s.busy=s.nextShot; Combat.melee(player,dir,d); Combat.send(player,"Fired",{id=d.id,slash=true})
	elseif d.shield then s.blocking=not s.blocking
	elseif d.warp then Combat.Utility.warp(player,dir,d.warp,d.warpCooldown,true)
	elseif d.kind=="satchel" then Combat.Utility.detonate(player)
	elseif d.charge then s.trigger=nil
	elseif s.grapple then s.grapple=nil end
	Combat.snapshot(player)
end
function Combat.step(dt,now)
	for player,s in pairs(Combat.States) do
		local alive,h,r=Combat.alive(player)
		if alive then
			local d=Weapons.ById[s.loadout[s.slot]]
			s.heat=math.max(0,s.heat-dt*(d.cooling or 0.3)); if s.overheated and s.heat<0.2 then s.overheated=false end
			s.bloom=math.max(0,(s.bloom or 0)-dt*1.5)
			local speed=s.sprint and 22 or 16
			if s.crouch then speed=9 end
			if s.blocking then speed*=0.55 end
			if s.slowUntil and now<s.slowUntil then speed*=s.slowScale end
			if s.buffUntil and now<s.buffUntil then speed*=1.15 end
			if d.moveScale and now-(s.lastShot or 0)<0.25 then speed*=d.moveScale end
			h.WalkSpeed=speed
			if now<(s.slideUntil or 0) then
				local v=s.slideDirection*28; r.AssemblyLinearVelocity=Vector3.new(v.X,r.AssemblyLinearVelocity.Y,v.Z)
			end
			if s.grapple then
				local g=s.grapple; local delta=g.position-r.Position
				if now>g.untilTime or delta.Magnitude<5 or not Combat.line(r.Position,g.position,nil,player) then s.grapple=nil
				else
					local target=delta.Unit*math.min(55,delta.Magnitude*3)
					r.AssemblyLinearVelocity=r.AssemblyLinearVelocity:Lerp(target,math.min(1,dt*5))
				end
			end
			if s.mode~="Lobby" then
				-- Broad movement envelope; intentional impulses remain below these limits.
				local window=s.movementWindow or {position=r.Position,time=now}
				if (r.Position-window.position).Magnitude>110*(now-window.time)+8 then
					player.Character:PivotTo(CFrame.new(s.lastPosition or window.position)); r.AssemblyLinearVelocity=Vector3.zero
				end
				if now-window.time>=0.25 then window={position=r.Position,time=now} end
				s.movementWindow=window
				if not Combat.World.inBounds(r.Position,s.mode) then
					local origin=s.mode=="Range" and Combat.World.Origin or Combat.World.ArenaOrigin
					player.Character:PivotTo(CFrame.new(origin+Vector3.new(0,5,60))); r.AssemblyLinearVelocity=Vector3.zero
				end
				s.lastPosition=r.Position
			end
			if (s.burnUntil or 0)>now and now>(s.nextBurn or 0) then
				s.nextBurn=now+0.5
				Combat.damage(s.burnOwner,player.Character,3,r,r.Position,s.burnDef,true)
			end
		else
			if s.trigger or s.grapple then s.trigger=nil; s.grapple=nil; s.epoch+=1 end
		end
	end
end
return Combat
