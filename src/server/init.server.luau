local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Shared=game.ReplicatedStorage:WaitForChild("ZIVRA")
local Rules=require(Shared.Rules)
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
local matches={}; local invitations={}; local arenaReady=0; local nextMatch=0; local connections={}; local shuttingDown=false
local finishMatch
local function lobby(player)
	local s=Combat.States[player]; if not s then return end
	if s.match then finishMatch(s.match,nil,"Duel ended") end
	Combat.transition(player,"Lobby",World.LobbyCFrame)
end
local function enterRange(player)
	local s=Combat.States[player]
	if not s or s.mode~="Lobby" or not Combat.alive(player) then return end
	Combat.transition(player,"Range",CFrame.new(World.Origin+Vector3.new(0,5,80)))
end
finishMatch=function(id,winner,message)
	local match=matches[id]; if not match then return end
	matches[id]=nil; arenaReady=os.clock()+2.2
	for _,player in ipairs(match.players) do
		local s=Combat.States[player]
		if s then
			s.match=nil
			if winner then
				local daily=Profiles.daily(s.profile); daily.duels+=1; s.profile.stats.duels+=1
				if winner==player then daily.wins+=1; s.profile.stats.wins+=1; s.profile.currency+=25 end
			end
			Combat.cleanup(player); s.mode="Lobby"; s.epoch+=1; s.trigger=nil; s.grapple=nil
			Combat.send(player,"Notice",message or (winner==player and "Duel won +25" or "Duel complete"))
			task.delay(2,function()
				if Combat.States[player]==s and s.mode=="Lobby" then
					if Combat.alive(player) then Combat.transition(player,"Lobby",World.LobbyCFrame)
					else player:LoadCharacterAsync() end
				end
			end)
		end
	end
end
Combat.onElimination=function(winner,victim)
	local s=Combat.States[victim]
	if s and s.match then finishMatch(s.match,winner) end
end
local function startDuel(first,second)
	-- One physical arena: serialize matches until instanced arenas are introduced.
	if next(matches) or os.clock()<arenaReady then return false end
	local a,b=Combat.States[first],Combat.States[second]
	if not a or not b or a.mode~="Lobby" or b.mode~="Lobby" or not Combat.alive(first) or not Combat.alive(second) then return false end
	nextMatch+=1; local id=nextMatch
	matches[id]={players={first,second},expires=os.clock()+180}
	for i,p in ipairs({first,second}) do
		invitations[p]=nil
		local cs=Combat.States[p]; cs.match=id; cs.eliminated=false
		local position=World.ArenaOrigin+Vector3.new(0,5,i==1 and 60 or -60)
		Combat.transition(p,"Duel",CFrame.lookAt(position,World.ArenaOrigin+Vector3.new(0,5,0)))
		cs.busy=os.clock()+3; Combat.snapshot(p,"Duel starts in 3 seconds")
	end
	return true
end
local function queue(player)
	local s=Combat.States[player]; if not s or s.mode~="Lobby" or not Combat.alive(player) then return end
	s.queued=not s.queued; Combat.snapshot(player,s.queued and "Waiting for an opponent" or "Left queue")
	if not s.queued then return end
	for other,os in pairs(Combat.States) do
		if other~=player and os.queued and os.mode=="Lobby" and Combat.alive(other) then startDuel(player,other); break end
	end
end
World.build(enterRange,lobby,queue)
local function characterAdded(player,character)
	local h=character:WaitForChild("Humanoid",10); local root=character:WaitForChild("HumanoidRootPart",10)
	if not h or not root then return end
	local s=Combat.States[player]; if not s then return end
	if s.match then finishMatch(s.match,nil,"Duel ended after respawn") end
	s.eliminated=false
	Combat.transition(player,"Lobby",World.LobbyCFrame)
	if connections[player] and connections[player].death then connections[player].death:Disconnect() end
	local death=h.Died:Connect(function()
		Combat.cleanup(player); s.epoch+=1; s.trigger=nil; s.blocking=false; s.grapple=nil
		if s.match and not s.pendingElimination then finishMatch(s.match,nil,"Duel ended") end
	end)
	if connections[player] then connections[player].death=death else death:Disconnect() end
end
local function added(player)
	local profile,offline=Profiles.load(player)
	if not profile then return end
	if not player.Parent then Profiles.save(player,true); return end
	Combat.add(player,profile,offline); connections[player]={}
	connections[player].character=player.CharacterAdded:Connect(function(c) characterAdded(player,c) end)
	if player.Character then task.spawn(characterAdded,player,player.Character) end
	Combat.snapshot(player,offline)
end
Players.PlayerAdded:Connect(added)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(added,player) end
Players.PlayerRemoving:Connect(function(player)
	local s=Combat.States[player]
	if s and s.match then finishMatch(s.match,nil,"Opponent disconnected; no win reward") end
	Combat.cleanup(player); Combat.States[player]=nil; invitations[player]=nil
	for target,invite in pairs(invitations) do if invite.from==player then invitations[target]=nil end end
	if connections[player] then for _,c in pairs(connections[player]) do c:Disconnect() end; connections[player]=nil end
	Profiles.save(player,true)
end)
local function settings(s,value)
	if type(value)~="table" then return end
	local p=s.profile.settings
	if ({Low=true,Medium=true,High=true,Automatic=true})[value.quality] then p.quality=value.quality end
	if type(value.reduceFlash)=="boolean" then p.reduceFlash=value.reduceFlash end
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
	elseif action=="Queue" then if os.clock()>(s.nextQueue or 0) then s.nextQueue=os.clock()+1; queue(player) end
	elseif action=="Invite" then
		if s.mode=="Lobby" and Rules.finite(value) and os.clock()>(s.nextInvite or 0) then
			s.nextInvite=os.clock()+5
			local target=Players:GetPlayerByUserId(value); local ts=target and Combat.States[target]
			if ts and target~=player and ts.mode=="Lobby" and not ts.queued and not s.queued and not invitations[target] then
				invitations[target]={from=player,expires=os.clock()+20}
				Combat.send(target,"Invite",{userId=player.UserId,name=player.DisplayName,duration=20})
				Combat.snapshot(player,"Duel invitation sent")
			end
		end
	elseif action=="AcceptInvite" or action=="DeclineInvite" then
		local invite=invitations[player]; invitations[player]=nil
		if action=="AcceptInvite" and invite and invite.expires>os.clock() then
			if not startDuel(invite.from,player) then Combat.snapshot(player,"Arena busy or invitation unavailable; use the duel queue") end
		end
	elseif action=="ResetRange" then
		if s.mode=="Range" and os.clock()>(s.nextReset or 0) then s.nextReset=os.clock()+5; Combat.reset(player); s.rangeStats={shots=0,hits=0,damage=0,started=os.clock()} end
	elseif action=="Sprint" then if type(value)=="boolean" then s.sprint=value; if value then s.crouch=false end end
	elseif action=="Crouch" then
		local alive,h,r=Combat.alive(player)
		if alive and not s.menu and os.clock()>(s.nextSlide or 0) then
			if s.sprint and h.MoveDirection.Magnitude>0.5 and h.FloorMaterial~=Enum.Material.Air then
				s.slideUntil=os.clock()+0.55; s.slideDirection=h.MoveDirection.Unit; s.nextSlide=os.clock()+1.8; s.crouch=false; s.sprint=false
				Combat.send(player,"Slide",{duration=0.55})
			else s.crouch=not s.crouch; s.sprint=false end
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
		for id,m in pairs(matches) do if now>m.expires then finishMatch(id,nil,"Duel timed out") end end
		for target,invite in pairs(invitations) do if now>invite.expires then invitations[target]=nil end end
		if not next(matches) and now>=arenaReady then
			local first
			for p,s in pairs(Combat.States) do
				if s.queued and s.mode=="Lobby" and Combat.alive(p) then
					if first then startDuel(first,p); break else first=p end
				end
			end
		end
	end
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
