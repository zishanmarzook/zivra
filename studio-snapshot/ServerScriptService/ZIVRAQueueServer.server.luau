local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Shared=RS:WaitForChild('ZIVRA')
local Config=require(Shared.Config)
local Adapter=require(Shared.MatchAdapter)
local Remote=Shared.QueueAction
local Stations=workspace:WaitForChild('ZIVRA_Corridor'):WaitForChild('Stations')
local states,membership,cooldown,lastRequest={},{},{},{}
for _,spec in ipairs(Config.Stations) do states[spec.Id]={spec=spec,model=Stations:WaitForChild(spec.Id),players={},deadline=nil,message=nil} end
local function alive(player)
 local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
 return h and h.Health>0 and r
end
local function inside(player,state)
 if player:GetAttribute('ZIVRAInMatch') then return false end
 local r=alive(player);if not r then return false end
 local zone=state.model.QueueZone;local p=zone.CFrame:PointToObjectSpace(r.Position);local s=zone.Size/2
 return math.abs(p.X)<=s.X and math.abs(p.Y)<=s.Y and math.abs(p.Z)<=s.Z
end
local function remove(player)
 local state=membership[player];if not state then return end
 state.players[player]=nil;membership[player]=nil;state.deadline=nil
 if player.Parent==Players then Remote:FireClient(player,'Left') end
end
Remote.OnServerEvent:Connect(function(player,action)
 if action~='Leave' then return end
 local now=os.clock();if now-(lastRequest[player] or 0)<0.5 then return end;lastRequest[player]=now
 remove(player);cooldown[player]=now+Config.DepartureCooldown
end)
Players.PlayerRemoving:Connect(function(player) remove(player);cooldown[player]=nil;lastRequest[player]=nil end)
while true do
 local now=os.clock()
 for player,state in pairs(membership) do if player.Parent~=Players or not inside(player,state) then remove(player) end end
 for _,player in ipairs(Players:GetPlayers()) do
  if not membership[player] and now>=(cooldown[player] or 0) then
   for _,spec in ipairs(Config.Stations) do
    local state=states[spec.Id];local n=0;for _ in pairs(state.players) do n+=1 end
    if not state.busy and now>=(state.lockUntil or 0) and n<spec.Capacity and inside(player,state) then
     state.players[player]=true;membership[player]=state;Remote:FireClient(player,'Joined',spec.Id);break
    end
   end
  end
 end
 for _,spec in ipairs(Config.Stations) do
  local state=states[spec.Id];local list={};for p in pairs(state.players) do table.insert(list,p) end
  local full=#list==spec.Capacity
  if not full then state.deadline=nil elseif not state.deadline and not state.busy then state.deadline=now+Config.Countdown end
  local status=state.message or 'STEP ONTO PLATFORM'
  if state.deadline then status='STARTING IN '..math.max(0,math.ceil(state.deadline-now)) end
  state.model:SetAttribute('QueueCount',#list);state.model:SetAttribute('Capacity',spec.Capacity);state.model:SetAttribute('Status',status)
  state.model.Screen.SurfaceGui.Display.Text=spec.Label..'\n'..#list..'/'..spec.Capacity..'\n'..status
  if full and state.deadline and now>=state.deadline and not state.busy then
   state.busy=true;state.deadline=nil;state.message='PREPARING'
   -- Teleports can yield; never block scanning other queues.
   task.spawn(function()
    local valid={};for _,p in ipairs(list) do if membership[p]==state and inside(p,state) then table.insert(valid,p) end end
    local ok,msg=false,'QUEUE RESET'
    if #valid==spec.Capacity then ok,msg=Adapter.Start(spec,valid) end
    state.message=msg;state.lockUntil=os.clock()+5
    for _,p in ipairs(list) do if membership[p]==state then remove(p);cooldown[p]=os.clock()+Config.DepartureCooldown;Remote:FireClient(p,'Notice',msg) end end
    state.busy=false
    task.delay(5,function() state.message=nil end)
   end)
  end
 end
 task.wait(Config.ScanInterval)
end
