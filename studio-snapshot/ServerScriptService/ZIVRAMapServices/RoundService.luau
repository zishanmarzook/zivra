local Players=game:GetService('Players')
local Teams=game:GetService('Teams')
local Shared=game.ReplicatedStorage.ZIVRAMapShared
local C=require(Shared.MapConfig);local Maps=require(script.Parent.MapService);local Spawn=require(script.Parent.SpawnService)
local Remote=Shared.MapSelection
local R={Current=nil,Completed=Instance.new('BindableEvent')};local requests={}
local function packet(s,kind,extra)
 for p in pairs(s.members) do if p.Parent==Players then Remote:FireClient(p,kind,extra) end end
end
local function finish(s,message,winner)
 if R.Current~=s then return end
 R.Current=nil
 local valid=s.phase=='Playing' and s.started and os.clock()-s.started>=10 and (winner==1 or winner==2)
 R.Completed:Fire(s.members,winner,valid,message)
 for _,cn in s.connections do cn:Disconnect() end
 for p,data in pairs(s.members) do
  if p.Parent==Players then
   Spawn.Lobby(p,data.team,data.neutral);Remote:FireClient(p,'Lobby',{message=message})
  end
 end
 Maps.Unload()
 for _,team in s.teams do team:Destroy() end
end
R.Finish=function(message) if R.Current then finish(R.Current,message or 'MATCH ENDED') end end
function R.Start(spec,participants)
 if R.Current then return false,'ARENA BUSY â€” TRY AGAIN' end
 local mode=C.ModeAliases[spec.Id] or spec.Id
 local eligible=Maps.Eligible(mode)
 if #eligible==0 then return false,'MODE NOT AVAILABLE YET' end
 if #participants<2 or #participants%2~=0 or #participants~=spec.Capacity then return false,'INVALID TEAM SIZE' end
 if spec.TeamAssignments then
  local counts={0,0};for _,p in participants do local side=spec.TeamAssignments[p.UserId];if side~=1 and side~=2 then return false,'INVALID TEAM ASSIGNMENT' end;counts[side]+=1 end
  if counts[1]~=#participants/2 or counts[2]~=#participants/2 then return false,'UNBALANCED TEAMS' end
 end
 local s={members={},votes={},connections={},teams={},phase='Voting',eligible=eligible}
 for _,p in participants do
  if s.members[p] then return false,'DUPLICATE PLAYER' end
  local c=p.Character;local h=c and c:FindFirstChildOfClass('Humanoid')
  if not h or h.Health<=0 or p:GetAttribute('ZIVRAInMatch') then return false,'PLAYER NOT READY' end
  s.members[p]={team=p.Team,neutral=p.Neutral,alive=true}
 end
 R.Current=s
 for p in pairs(s.members) do p:SetAttribute('ZIVRAInMatch',true) end
 packet(s,'Vote',{maps=eligible,mode=mode,deadline=workspace:GetServerTimeNow()+C.VoteSeconds})
 task.spawn(function()
  task.wait(C.VoteSeconds)
  if R.Current~=s then return end
  local counts={};for _,id in eligible do counts[id]=0 end
  local count=0;for p in pairs(s.members) do if p.Parent==Players then count+=1 end end
  if count~=#participants then finish(s,'MATCH CANCELLED â€” PLAYER LEFT');return end
  for p,id in pairs(s.votes) do if s.members[p] then counts[id]+=1 end end
  local selected=eligible[math.random(1,#eligible)]
  for _,id in eligible do if counts[id]>counts[selected] then selected=id end end
  local ok,active=pcall(Maps.Load,selected)
  if not ok then warn('ZIVRA map load:',active);finish(s,'MAP FAILED TO LOAD');return end
  s.phase='Preparing';s.ready={};s.preparation=game:GetService('HttpService'):GenerateGUID(false)
  packet(s,'Prepare',{map=selected,token=s.preparation,origin=C.Origin.Position})
  local preparationDeadline=os.clock()+12
  local allReady=false
  repeat
   allReady=true
   for p in pairs(s.members) do if not s.ready[p] then allReady=false;break end end
   if not allReady then task.wait(0.1) end
  until allReady or R.Current~=s or os.clock()>=preparationDeadline
  if R.Current~=s then return end
  if not allReady then finish(s,'MAP STREAMING TIMED OUT â€” TRY AGAIN');return end
  s.phase='Playing';s.started=os.clock()
  for _,name in {'A','B'} do
   local t=Instance.new('Team');t.Name='ZIVRA Match '..name;t.TeamColor=BrickColor.new(name=='A' and 'Bright blue' or 'Bright orange');t.AutoAssignable=false;t.Parent=Teams;table.insert(s.teams,t)
  end
  local shuffled=table.clone(participants)
  if spec.TeamAssignments then
   table.sort(shuffled,function(a,b)
    local sa,sb=spec.TeamAssignments[a.UserId],spec.TeamAssignments[b.UserId]
    return sa==sb and a.UserId<b.UserId or sa<sb
   end)
  else for i=#shuffled,2,-1 do local j=math.random(i);shuffled[i],shuffled[j]=shuffled[j],shuffled[i] end end
  local half=#shuffled/2
  for i,p in shuffled do
   local side=i<=half and 1 or 2;local index=(i-1)%half+1
   local marker=active.Model.Spawns:FindFirstChild(string.format('Team%s_Spawn_%02d',side==1 and 'A' or 'B',index))
   if not marker or not Spawn.Place(p,marker,s.teams[side]) then finish(s,'SPAWN FAILED');return end
   s.members[p].side=side
   local h=p.Character.Humanoid
   table.insert(s.connections,h.Died:Connect(function()
    if R.Current~=s then return end
    s.members[p].alive=false
    local alive={0,0};for q,data in pairs(s.members) do if q.Parent==Players and data.alive then alive[data.side]+=1 end end
    if alive[1]==0 or alive[2]==0 then task.delay(1.5,function() if R.Current==s then finish(s,alive[1]==alive[2] and 'DRAW' or 'TEAM '..(alive[1]>0 and 'A' or 'B')..' WINS',alive[1]>0 and 1 or alive[2]>0 and 2 or nil) end end) end
   end))
   table.insert(s.connections,p.CharacterAdded:Connect(function()
    if R.Current==s then s.members[p].alive=false;Remote:FireClient(p,'Lobby',{message='ELIMINATED â€” ROUND CONTINUES'}) end
   end))
  end
  active.Zone:SetAttribute('Enabled',true)
  packet(s,'Playing',{map=selected,deadline=workspace:GetServerTimeNow()+C.RoundSeconds})
  while R.Current==s and os.clock()-s.started<C.RoundSeconds do
   for p,data in pairs(s.members) do
    local c=p.Character;local root=c and c:FindFirstChild('HumanoidRootPart')
    if data.alive and root and root.Position.Y<C.Origin.Position.Y+(active.Model:GetAttribute('KillY') or -20) then c.Humanoid.Health=0 end
   end
   task.wait(0.3)
  end
  if R.Current==s then finish(s,'ROUND TIME LIMIT') end
 end)
 return true,'MAP VOTE STARTED'
end
Remote.OnServerEvent:Connect(function(player,action,id)
 if action=='Ready' then
  local s=R.Current
  if s and s.phase=='Preparing' and s.members[player] and id==s.preparation then s.ready[player]=true end
  return
 end
 if action~='Vote' or type(id)~='string' then return end
 local now=os.clock();if now-(requests[player] or 0)<0.2 then return end;requests[player]=now
 local s=R.Current
 if not s or s.phase~='Voting' or not s.members[player] or not table.find(s.eligible,id) then return end
 s.votes[player]=id;Remote:FireClient(player,'Selected',{map=id})
end)
Players.PlayerRemoving:Connect(function(p)
 requests[p]=nil;local s=R.Current
 if s and s.members[p] then finish(s,'MATCH ENDED â€” PLAYER LEFT') end
end)
return R