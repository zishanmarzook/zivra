local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage.ZIVRAHQ
local Config=require(Shared.Config)
local Launch=require(game.ReplicatedStorage.ZIVRA.Config).Launch1v1
local Core=require(script.Parent.PartyCore)
local Stats=require(script.Parent.SessionStats)
local Round=require(game.ServerScriptService.ZIVRAMapServices.RoundService)
local Remote=Shared.Request
local S={Core=Core.new()}
local modes={};for _,v in Config.Modes do modes[v.Id]=v end
local buckets={};local revisions={};local training={}
local function notify(p,message) if p and p.Parent==Players then Remote:FireClient(p,'Notice',message) end end
function S.Push(p)
 if p.Parent~=Players then return end
 local party=S.Core:Create(p.UserId);local members={}
 for _,id in party.members do local q=Players:GetPlayerByUserId(id);if q then table.insert(members,{id=id,name=q.DisplayName,username=q.Name,ready=party.ready[id]==true}) end end
 local roster={};for _,q in Players:GetPlayers() do
  local d=Stats.Get(q);table.insert(roster,{id=q.UserId,name=q.DisplayName,wins=d.Wins,kills=d.Eliminations})
 end
 table.sort(roster,function(a,b) return a.wins==b.wins and a.id<b.id or a.wins>b.wins end)
 revisions[p]=(revisions[p] or 0)+1
 Remote:FireClient(p,'State',{revision=revisions[p],party={leader=party.leader,members=members,mode=party.mode,status=party.state,queuedAt=party.queuedAt},profile=Stats.Snapshot(p),roster=roster,invite=S.Core.invites[p.UserId],training=p:GetAttribute('ZIVRATraining')==true})
end
function S.Broadcast() for _,p in Players:GetPlayers() do S.Push(p) end end
local function eligible(p)
 local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
 return (not p:GetAttribute('ZIVRACombatMode') or p:GetAttribute('ZIVRACombatMode')=='Lobby') and h and h.Health>0 and not p:GetAttribute('ZIVRAInMatch') and not p:GetAttribute('ZIVRATraining')
end
function S.Request(p,action,value)
 local now=os.clock();local b=buckets[p] or {tokens=16,time=now};buckets[p]=b
 b.tokens=math.min(16,b.tokens+(now-b.time)*8);b.time=now
 if b.tokens<1 or type(action)~='string' then return end;b.tokens-=1
 if action=='Sync' then S.Push(p);return end
 if Launch and action~='Setting' then return end
 if p:GetAttribute('ZIVRACombatMode') and p:GetAttribute('ZIVRACombatMode')~='Lobby' then notify(p,'Return to headquarters first.');return end
 if action=='Invite' then
  if type(value)~='number' or value%1~=0 then return end
  local target=Players:GetPlayerByUserId(value)
  if not target or not eligible(p) or not eligible(target) then notify(p,'Player is not available in this lobby.');return end
  local ok,message=S.Core:Invite(p.UserId,value,workspace:GetServerTimeNow(),Config.InviteSeconds)
  if not ok then notify(p,message) else notify(target,p.DisplayName..' invited you to a party. Open FRIENDS.');S.Broadcast() end;return
 elseif action=='Training' then
  local party=S.Core:Create(p.UserId)
  if not eligible(p) or party.state~='Idle' then notify(p,'Leave matchmaking before training.');return end
  p:SetAttribute('ZIVRATraining',true);training[p]=true
  local c=p.Character;c:SetAttribute('ZIVRAMovementExemptUntil',workspace:GetServerTimeNow()+2);c:PivotTo(CFrame.lookAt(Vector3.new(-88,34,61),Vector3.new(-88,34,100)))
  local tool=p.Backpack:FindFirstChildOfClass('Tool');if tool then c.Humanoid:EquipTool(tool) end
 elseif action=='LeaveTraining' then
  if not p:GetAttribute('ZIVRATraining') or p:GetAttribute('ZIVRAInMatch') then return end
  p:SetAttribute('ZIVRATraining',nil);training[p]=nil
  require(game.ServerScriptService.ZIVRAMapServices.SpawnService).Lobby(p,p.Team,p.Neutral)
 elseif action=='ResetTraining' then
  local d=Stats.Get(p);d.Shots=0;d.Hits=0;d.Targets=0
 elseif action=='Equip' then
  if value~='M4' or p:GetAttribute('ZIVRAInMatch') then return end
  local tool=p.Backpack:FindFirstChildOfClass('Tool');local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  if tool and h then h:EquipTool(tool) end;notify(p,'M4 equipped. This is the current available loadout.')
 elseif action=='Setting' then
  if type(value)~='table' then return end
  local settings=Stats.Get(p).Settings
  if (value.key=='ReducedMotion' or value.key=='AutoSprint') and type(value.value)=='boolean' then settings[value.key]=value.value
  elseif value.key=='FOV' and type(value.value)=='number' and value.value==value.value then settings.FOV=math.clamp(value.value,65,95) end
 elseif action=='Claim' then
  local d=Stats.Get(p)
  if d.Matches>=3 and not d.Claimed then d.Claimed=true;d.XP+=100;notify(p,'Mission complete: +100 session XP.') else notify(p,'Complete three valid matches. Reward can be claimed once per session.') end
 else
  if action=='Queue' then local party=S.Core:Create(p.UserId)
   for _,id in party.members do local q=Players:GetPlayerByUserId(id);if not q or not eligible(q) then notify(p,'Every member must be alive and in the lobby.');return end end
  end
  if (action=='Kick' or action=='Transfer') and type(value)~='number' then return end
  if action=='Mode' and type(value)~='string' then return end
  local ok,message=S.Core:Action(p.UserId,action,value,modes,workspace:GetServerTimeNow())
  if not ok then notify(p,message) end
 end
 S.Broadcast()
end
Remote.OnServerEvent:Connect(S.Request)
local function added(p)
 Stats.Get(p);S.Core:Create(p.UserId)
 p.CharacterAdded:Connect(function(c)
  p:SetAttribute('ZIVRATraining',nil);training[p]=nil
  local h=c:WaitForChild('Humanoid',10);if h then h.Died:Connect(function()
   local party=S.Core:Get(p.UserId);if party and party.state=='Searching' then S.Core:Cancel(party);S.Broadcast() end
  end) end
 end)
 task.defer(S.Broadcast)
end
Players.PlayerAdded:Connect(added)
for _,p in Players:GetPlayers() do added(p) end
Players.PlayerRemoving:Connect(function(p) S.Core:Disconnect(p.UserId);Stats.Data[p]=nil;buckets[p]=nil;revisions[p]=nil;training[p]=nil;task.defer(S.Broadcast) end)
Round.Completed.Event:Connect(function(members,winner,valid,message)
 for p,data in pairs(members) do if p.Parent==Players then
  local d=Stats.Get(p)
  if valid then d.Matches+=1;d.XP+=50;if winner==data.side then d.Wins+=1;d.XP+=50 end;if not data.alive then d.Deaths+=1 end end
  Remote:FireClient(p,'Result',{message=message,xp=valid and (winner==data.side and 100 or 50) or 0})
 end end
 for _,party in pairs(S.Core.parties) do if party.state=='InMatch' then party.state='Idle';party.ready={};party.queuedAt=nil end end
 S.Broadcast()
end)
task.spawn(function()
 while true do
  if not Launch and not Round.Current then
   for _,mode in {'Duel','Team'} do
    local match=S.Core:FindMatch(mode,modes[mode].TeamSize)
    if match then
     local roster,assignments={},{};local valid=true
     for _,party in match.parties do for _,id in party.members do local p=Players:GetPlayerByUserId(id)
      if not p or not eligible(p) then valid=false else table.insert(roster,p);assignments[id]=match.teams[party.id] end
     end end
     if valid then
      local ok,message=Round.Start({Id=mode,Capacity=modes[mode].Players,TeamAssignments=assignments},roster)
      for _,party in match.parties do party.state=ok and 'InMatch' or 'Idle';if not ok then party.ready={} end end
      for _,p in roster do notify(p,ok and 'Match found. Choose your arena.' or message) end
     else for _,party in match.parties do S.Core:Cancel(party) end end
     S.Broadcast();break
    end
   end
  end
  for _,p in Players:GetPlayers() do
   local c=p.Character;local root=c and c:FindFirstChild('HumanoidRootPart')
   if root and (p:GetAttribute('ZIVRACombatMode') or 'Lobby')=='Lobby' and not p:GetAttribute('ZIVRAInMatch') and root.Position.Y<20 then require(game.ServerScriptService.ZIVRAMapServices.SpawnService).Lobby(p,p.Team,p.Neutral) end
  end
  task.wait(Config.QueueInterval)
 end
end)
local function station(term)
 local prompt=term:FindFirstChildOfClass('ProximityPrompt');if not prompt then return end
 if Launch then
  local page,mode=term:GetAttribute('Page'),term:GetAttribute('Mode')
  if page~='Loadout' and not (page=='Play' and (mode=='Duel' or not mode)) then
   prompt.Enabled=false
   for _,child in term:GetDescendants() do
    if child:IsA('SurfaceGui') or child:IsA('BillboardGui') then child.Enabled=false end
   end
   return
  end
 end
 prompt.Triggered:Connect(function(p)
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  if root and (root.Position-term.Position).Magnitude<=12 and not p:GetAttribute('ZIVRAInMatch') then
   local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={p.Character};ray.RespectCanCollide=true
   local hit=workspace:Raycast(root.Position,term.Position-root.Position,ray)
   if not hit or hit.Instance==term then Remote:FireClient(p,'Open',{page=term:GetAttribute('Page'),mode=term:GetAttribute('Mode')}) end
  end
 end)
end
for _,term in workspace.ZIVRA_Corridor.Terminals:GetChildren() do station(term) end
task.spawn(function()
 while true do
  if Launch then return end
  local board=workspace.ZIVRA_Corridor:FindFirstChild('LeaderboardBoard',true)
  if board then local label=board:FindFirstChild('Display',true)
   if label then
    local rows={};for _,p in Players:GetPlayers() do table.insert(rows,{p=p,w=Stats.Get(p).Wins}) end
    table.sort(rows,function(a,b) return a.w>b.w end)
    local text='THIS SERVER / SESSION WINS'
    for i=1,math.min(5,#rows) do text..='\n'..i..'  '..rows[i].p.DisplayName..'  /  '..rows[i].w end
    label.Text=text
   end
  end
  for p in pairs(training) do if p.Parent==Players then S.Push(p) end end
  task.wait(2)
 end
end)
return S