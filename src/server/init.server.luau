local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Shared=game.ReplicatedStorage:WaitForChild("ZIVRA")
local Rules=require(Shared.Rules)
local Config=require(Shared.Config)
local Weapons=require(Shared.Weapons)
local Duel=require(script.Duel)
local Traversal=require(script.Traversal)
local Profiles=require(script.Profiles)
local World=require(script.World)
local Combat=require(script.Combat)
local Projectiles=require(script.Projectiles)
local Utility=require(script.Utility)
assert(not Shared:FindFirstChild("Request"),"Duplicate ZIVRA combat runtime; remove duplicate installation")
local request=Instance.new("RemoteEvent"); request.Name="Request"; request.Parent=Shared
local feedback=Instance.new("RemoteEvent"); feedback.Name="Feedback"; feedback.Parent=Shared
Combat.init(feedback,World,Profiles); Combat.Projectiles=Projectiles; Combat.Utility=Utility
Projectiles.init(Combat); Utility.init(Combat)
if Config.Launch1v1 then
 local storage=Instance.new("Folder"); storage.Name="ZIVRA_InactiveStarterTools"; storage.Parent=game.ServerStorage
 for _,item in game.StarterPack:GetChildren() do if item:IsA("Tool") then item.Parent=storage end end
end
local stashed={}
local function tools(player)
    local active=player:GetAttribute("ZIVRACombatMode")~="Lobby" and player:GetAttribute("ZIVRACombatMode")~=nil
    if active then
        local folder=stashed[player]
        if not folder then folder=Instance.new("Folder");folder.Name="ZIVRA_Stashed_"..player.UserId;folder.Parent=game.ServerStorage;stashed[player]=folder end
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if h then h:UnequipTools() end
        for _,container in {player.Backpack,player.Character} do if container then for _,item in container:GetChildren() do if item:IsA("Tool") then item.Parent=folder end end end end
    elseif stashed[player] then
        for _,item in stashed[player]:GetChildren() do item.Parent=player.Backpack end
        stashed[player]:Destroy();stashed[player]=nil
    end
end
local match
local queueOrder=0
local connections={}
local shuttingDown=false
local function publishMatch(current)
	for side,player in ipairs(current.players) do
		local s=Combat.States[player]
		if s and s.mode=="Duel" and s.duel and s.duel.id==current and player.Parent==Players then
			player:SetAttribute("ZIVRADuelPhase",current.phase)
			local opponent=3-side
			s.duel={
				id=current, phase=current.phase,
			}
			s.duelView={
				phase=current.phase, round=current.round, reason=current.reason,
				deadline=workspace:GetServerTimeNow()+math.max(0,current.deadline-os.clock()),
				name=player.DisplayName, opponent=current.players[opponent].DisplayName,
				score=current.score[side], opponentScore=current.score[opponent],
				eliminations=current.eliminations[side], opponentEliminations=current.eliminations[opponent],
				won=current.winner==side, decided=current.winner~=nil,
				roundWon=current.roundWinner==side, roundDecided=current.roundWinner~=nil,
				rematchAllowed=current.rematchAllowed, rematch=current.rematch[side]==true,
				loadout=current.loadouts[side], confirmed=current.confirmed[side]==true,
				opponentConfirmed=current.confirmed[opponent]==true,
			}
			Combat.snapshot(player)
		end
	end
end

local function freeze(player,value)
	local _,_,root=Combat.alive(player)
	if root then
		root.AssemblyLinearVelocity=Vector3.zero
		root.AssemblyAngularVelocity=Vector3.zero
		root.Anchored=value
	end
end

local function returnToHQ(player)
	local s=Combat.States[player]
	if not s or player.Parent~=Players then return end
	local wasInArena=s.mode=="Duel"
	s.duel=nil
	s.duelView=nil
	s.duelLoadout=nil
	player:SetAttribute("ZIVRADuelPhase",nil)
	freeze(player,false)
	Combat.transition(player,"Lobby",World.LobbyCFrame)
	s.lobbyReturn=nil
	if wasInArena and not Combat.alive(player) and player.Character then
		-- The normal Roblox respawn will enter at the headquarters spawn.
		local root=player.Character:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored=false end
	end
end

local function releaseMatch(current)
	if match~=current then return end
	match=nil
	for _,player in ipairs(current.players) do
		local s=Combat.States[player]
		if s and s.duel and s.duel.id==current then returnToHQ(player) end
	end
end

local function cancelMatch(current, reason, departing)
	current:finish(nil,reason,os.clock())
	current.deadline=os.clock()+6
	for _,player in ipairs(current.players) do
		if player~=departing then freeze(player,true) end
	end
	publishMatch(current)
end

local function lobby(player)
	local s=Combat.States[player]
	if not s then return end
	if match and s.duel and s.duel.id==match then
		if match.phase~="Result" then
			cancelMatch(match,"Opponent returned to headquarters",player)
		else
			match.rematchAllowed=false
			publishMatch(match)
		end
		returnToHQ(player)
		local other=match.players[3-match:side(player)]
		local opponent=Combat.States[other]
		if not opponent or not opponent.duel then releaseMatch(match) end
	elseif s.mode~="Lobby" then
		returnToHQ(player)
	end
end

local function enterRange(player)
	local s=Combat.States[player]
	if Config.Launch1v1 or not s or s.mode~="Lobby" or not Combat.alive(player) then return end
	Combat.transition(player,"Range",CFrame.new(World.Origin+Vector3.new(0,5,80)))
end

local function roundEnded(current)
	for _,player in ipairs(current.players) do
		local s=Combat.States[player]
		s.epoch+=1
		s.trigger=nil
		s.busy=0
		Combat.cleanup(player)
		freeze(player,true)
		if current.phase=="Result" then
			local p=s.profile
			local daily=Profiles.daily(p)
			daily.duels+=1
			p.stats.duels+=1
			if current.players[current.winner]==player then
				daily.wins+=1
				p.stats.wins+=1
			end
		end
	end
	publishMatch(current)
end

local function resolveRound(winner,reason)
	if match and match:resolve(winner,reason,os.clock()) then roundEnded(match) end
end

Combat.onElimination=function(winner,victim,headshot)
	if match and match.phase=="Active" and match:side(winner) and match:side(victim) then
		Combat.send(winner,"Notice",headshot and "HEADSHOT ELIMINATION" or "ELIMINATION")
		resolveRound(match:side(winner),"Elimination")
	end
end

local function startDuel(first,second,now)
	local players={first,second}
	match=Duel.new(players,Config.Duel,now)
	for side,p in ipairs(players) do
		local s=Combat.States[p]
		s.duel={id=match, phase="Versus"}
		s.duelLoadout=nil
		match.loadouts[side]=table.clone(s.profile.loadout)
		p:SetAttribute("ZIVRAQueued",false)
		Combat.transition(p,"Duel",World.spawn(side,1))
		freeze(p,true)
	end
	publishMatch(match)
end

local function queue(player,wantsQueue)
	local s=Combat.States[player]
	if not s or s.mode~="Lobby" then return end
	if wantsQueue==nil then wantsQueue=not s.queued end
	if wantsQueue then
		if s.queued or s.readyCharacter~=player.Character or not Combat.alive(player) then return end
		queueOrder+=1
		s.queued=queueOrder
	else
		if not s.queued then return end
		s.queued=false
	end
	player:SetAttribute("ZIVRAQueued",s.queued and true or false)
	Combat.snapshot(player,s.queued and "Waiting for an opponent" or "Left queue")
end

local function matchStep(now)
	local current=match
	if not current then
		local candidates={}
		for p,s in pairs(Combat.States) do
			if s.queued and s.mode=="Lobby" and s.readyCharacter==p.Character and Combat.alive(p) then
				table.insert(candidates,p)
			end
		end
		table.sort(candidates,function(a,b) return Combat.States[a].queued<Combat.States[b].queued end)
		if candidates[2] then startDuel(candidates[1],candidates[2],now) end
		return
	end
	if current.phase=="Result" and current.rematchAllowed and current.rematch[1] and current.rematch[2]
		and Combat.alive(current.players[1]) and Combat.alive(current.players[2]) then
		startDuel(current.players[2],current.players[1],now)
		return
	end
	if now<current.deadline and not current:loadoutsLocked(now) then return end
	if current.phase=="Active" then
		local _,first=Combat.alive(current.players[1])
		local _,second=Combat.alive(current.players[2])
		if current:timeout(first and first.Health or 0,second and second.Health or 0,now) then roundEnded(current) end
	elseif current.phase=="Result" then
		releaseMatch(current)
	elseif current.phase=="Versus" then
		current:openLoadout(now)
		publishMatch(current)
	elseif current.phase=="Countdown" then
		if not Combat.alive(current.players[1]) or not Combat.alive(current.players[2]) then
			cancelMatch(current,"A player did not respawn")
			return
		end
		current:begin(now)
		for _,player in ipairs(current.players) do freeze(player,false) end
		publishMatch(current)
	else
		for _,player in ipairs(current.players) do
			if not Combat.alive(player) then
				if now>=current.deadline+Config.Duel.RespawnGraceSeconds then cancelMatch(current,"A player did not respawn") end
				return
			end
		end
		current:countdown(now)
		for side,player in ipairs(current.players) do
			local s=Combat.States[player]
			s.duel.phase="Countdown"
			s.duelLoadout=current.loadouts[side]
			Combat.transition(player,"Duel",World.spawn(side,current.round))
			freeze(player,true)
		end
		publishMatch(current)
	end
end
World.build(enterRange,lobby,queue,function(player)
	local s=Combat.States[player]
	if s and s.mode=="Lobby" then Combat.send(player,"OpenMatchmaking") end
end)
local function characterAdded(player,character)
	local h=character:WaitForChild("Humanoid",10); local root=character:WaitForChild("HumanoidRootPart",10)
	if not h or not root or player.Character~=character then return end
	local s=Combat.States[player]; if not s then return end
	local inDuel=s.duel and match==s.duel.id
	if stashed[player] then stashed[player]:Destroy();stashed[player]=nil end
	if inDuel then
		if match.phase=="Active" then resolveRound(3-match:side(player),"Reset") end
		Combat.transition(player,"Duel",World.spawn(match:side(player),math.max(1,match.round)))
		freeze(player,true)
	else
		s.mode="Lobby"
		s.queued=false
		player:SetAttribute("ZIVRAQueued",false)
		player:SetAttribute("ZIVRACombatMode","Lobby")
		tools(player)
		if World.Headquarters then character:PivotTo(World.LobbyCFrame) end
		Combat.reset(player)
	end
	s.readyCharacter=character
	player:SetAttribute("ZIVRAReady",true)
    if connections[player] and connections[player].health then connections[player].health:Disconnect() end
    local lastHealth=h.Health
    connections[player].health=h.HealthChanged:Connect(function(value) if value<lastHealth then s.lastHit=os.clock() end;lastHealth=value end)
    if connections[player] and connections[player].death then connections[player].death:Disconnect() end
	local death=h.Died:Connect(function()
		Combat.cleanup(player); s.epoch+=1; s.trigger=nil; s.blocking=false; s.grapple=nil
		if s.duel and not s.pendingElimination and match==s.duel.id then
			resolveRound(3-match:side(player),"Opponent fell")
		elseif s.queued then
			s.queued=false; player:SetAttribute("ZIVRAQueued",false)
		end
	end)
	if connections[player] then connections[player].death=death else death:Disconnect() end
end
local function added(player)
	if World.Headquarters then player.RespawnLocation=World.Headquarters.spawn end
	local profile,offline=Profiles.load(player)
	if not profile then return end
	if not player.Parent then Profiles.save(player,true); return end
	Combat.add(player,profile,offline); connections[player]={}
    player:SetAttribute("ZIVRACombatMode","Lobby")
    connections[player].mode=player:GetAttributeChangedSignal("ZIVRACombatMode"):Connect(function() tools(player) end)
	connections[player].character=player.CharacterAdded:Connect(function(c) characterAdded(player,c) end)
	if player.Character then task.spawn(characterAdded,player,player.Character) end
	Combat.snapshot(player,offline)
end
Players.PlayerAdded:Connect(added)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(added,player) end
Players.PlayerRemoving:Connect(function(player)
	local s=Combat.States[player]
	if s and s.duel and match==s.duel.id then
		if match.phase=="Result" then
			match.rematchAllowed=false
			publishMatch(match)
		else
			cancelMatch(match,"Opponent disconnected",player)
		end
	end
	Combat.cleanup(player); Combat.States[player]=nil
	if connections[player] then for _,c in pairs(connections[player]) do c:Disconnect() end; connections[player]=nil end
	if stashed[player] then stashed[player]:Destroy();stashed[player]=nil end
	Profiles.save(player,true)
end)
local function settings(s,value)
	if type(value)~="table" then return end
	local p=s.profile.settings
	if ({Low=true,Medium=true,High=true,Automatic=true})[value.quality] then p.quality=value.quality end
	if type(value.reduceFlash)=="boolean" then p.reduceFlash=value.reduceFlash end
	if type(value.reducedMotion)=="boolean" then p.reducedMotion=value.reducedMotion end
	if type(value.autoSprint)=="boolean" then p.autoSprint=value.autoSprint end
	if Rules.finite(value.fov) then p.fov=math.clamp(value.fov,65,95) end
	if Rules.finite(value.volume) then p.volume=math.clamp(value.volume,0,1) end
	if Rules.finite(value.sensitivity) then p.sensitivity=math.clamp(value.sensitivity,0.2,2) end
	-- Position and scale overrides are constrained to the action-button safe region.
	if type(value.hud)=="table" then
		p.hud={}
		for _,id in ipairs({"Fire","Reload","Alt","Utility","Crouch","Sprint"}) do
			local v=value.hud[id]
			if ({Fire=true,Reload=true,Alt=true,Utility=true,Crouch=true,Sprint=true})[id] and type(v)=="table" and Rules.finite(v.x) and Rules.finite(v.y) and Rules.finite(v.size) then
				p.hud[id]={x=math.clamp(v.x,0.52,0.94),y=math.clamp(v.y,0.2,0.75),size=math.clamp(v.size,44,88)}
			end
		end
	end
end
request.OnServerEvent:Connect(function(player,action,value)
	local s=Combat.States[player]
	if not s or type(action)~="string" or not Rules.takeToken(s.bucket,os.clock(),36,50) then return end
	if action=="Sync" then
		if os.clock()>(s.nextSync or 0) then s.nextSync=os.clock()+1; Combat.snapshot(player) end
	elseif action=="Fire" or action=="Release" or action=="Alt" or action=="Utility" then
		local dir=Combat.direction(value); if not dir then return end
		if action=="Alt" then Combat.alternate(player,dir)
		elseif action=="Utility" then Utility.activate(player,dir)
		else Combat.fire(player,dir,action=="Release") end
	elseif action=="Trigger" then if type(value)=="boolean" then Combat.trigger(player,value) end
	elseif action=="Reload" then Combat.reload(player)
	elseif action=="Equip" then
		if type(value)=="string" and #value<=40 and os.clock()>(s.nextEquip or 0) then s.nextEquip=os.clock()+0.15; Combat.equip(player,value) end
	elseif action=="Menu" then
		if type(value)=="boolean" then s.menu=value; s.trigger=nil; s.blocking=false; if value then s.epoch+=1 end end
	elseif action=="Range" then enterRange(player)
	elseif action=="Lobby" then if s.mode~="Lobby" then lobby(player) end
	elseif action=="QueueJoin" then queue(player,true)
	elseif action=="QueueCancel" then queue(player,false)
	elseif action=="Queue" then
		if os.clock()>(s.nextQueue or 0) then s.nextQueue=os.clock()+0.5; queue(player) end
	elseif action=="ConfirmLoadout" then
		if match and s.duel and s.duel.id==match and match:confirm(player,value,os.clock(),Weapons,s.profile.owned) then
			publishMatch(match)
		end
	elseif action=="Rematch" then
		if match and s.duel and s.duel.id==match and match:vote(player) then
			local first,second=match.players[1],match.players[2]
			if Combat.alive(first) and Combat.alive(second) then startDuel(second,first,os.clock()) else publishMatch(match) end
		elseif match and s.duel and s.duel.id==match then
			publishMatch(match)
		end
	elseif action=="ResetRange" then
		if s.mode=="Range" and os.clock()>(s.nextReset or 0) then s.nextReset=os.clock()+5; Combat.reset(player); s.rangeStats={shots=0,hits=0,damage=0,started=os.clock()} end
	elseif action=="Sprint" and s.mode=="Range" then if type(value)=="boolean" then s.sprint=value; if value then s.crouch=false end end
	elseif action=="Crouch" and s.mode=="Range" then
		local alive,h,r=Combat.alive(player)
		if alive and not s.menu and os.clock()>(s.nextSlide or 0) then
			if s.sprint and h.MoveDirection.Magnitude>0.5 and h.FloorMaterial~=Enum.Material.Air then
				s.slideUntil=os.clock()+0.55; s.slideDirection=h.MoveDirection.Unit; s.nextSlide=os.clock()+1.8; s.crouch=false; s.sprint=false
				Combat.send(player,"Slide",{duration=0.55})
			else s.crouch=not s.crouch; s.sprint=false end
		end
	elseif action=="Traverse" then
		local dir=Combat.direction(value)
		local now=os.clock()
		if dir and math.abs(dir.Y)<0.1 and s.mode=="Duel" and Combat.permitted(s) and not s.menu and now>=(s.nextTraverse or 0) then
			s.nextTraverse=now+0.28
			local alive,humanoid,root=Combat.alive(player)
			if alive and not root.Anchored and humanoid.RigType==Enum.HumanoidRigType.R15 then
				local path=Traversal.find(player.Character,root,humanoid,dir,World.Arena)
				if path then
					s.nextTraverse=now+0.65
					local current,round=match,match.round
					Traversal.start(player,root,path,function()
						return match==current and current.round==round and Combat.permitted(s)
					end)
				end
			end
		end
	elseif action=="Settings" then
		if os.clock()>(s.nextSettings or 0) then s.nextSettings=os.clock()+0.3; settings(s,value); Combat.snapshot(player) end
	elseif action=="Claim" then
		local day=Profiles.daily(s.profile)
		local goals={duels=3,kills=15,wins=2}
		if type(value)=="string" and goals[value] and day[value]>=goals[value] and not day.claimed[value] then day.claimed[value]=true; s.profile.currency+=100; Combat.snapshot(player,"Task reward +100") end
	end
end)
local snapshotTime=0; local worldTime=0
RunService.Heartbeat:Connect(function(dt)
	local now=os.clock(); Combat.step(dt,now); Projectiles.step(dt); Utility.step()
	if now>worldTime then World.step(now); worldTime=now+0.05 end
	if now>snapshotTime then
		snapshotTime=now+0.3
		for player in pairs(Combat.States) do Combat.snapshot(player) end
	end
end)
local nextMatchStep=0
RunService.Heartbeat:Connect(function()
	local now=os.clock()
	if now<nextMatchStep then return end
	nextMatchStep=now+0.18
	matchStep(now)
	local queued=0
	for _,s in pairs(Combat.States) do if s.queued then queued+=1 end end
	World.queueStatus(queued,match~=nil)
end)
task.spawn(function()
	while not shuttingDown do
		task.wait(60)
		for player in pairs(Profiles.Sessions) do task.spawn(Profiles.save,player,false) end
	end
end)
game:BindToClose(function()
	shuttingDown=true
	local pending=0
	for player in pairs(Profiles.Sessions) do pending+=1; task.spawn(function() Profiles.save(player,true); pending-=1 end) end
	local deadline=os.clock()+25
	while pending>0 and os.clock()<deadline do task.wait(0.1) end
end)
