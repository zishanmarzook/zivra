-- ServerScriptService.ZIVRAWeapons.WeaponServer
local Players=game:GetService('Players')
local Shared=game.ReplicatedStorage:WaitForChild('ZIVRAWeapons')
local Config=require(Shared.WeaponConfig)
local V=require(script.Parent.WeaponValidation)
local Damage=require(script.Parent.DamageService)
local Request,State,Effects=Shared.WeaponRemotes.Request,Shared.WeaponRemotes.State,Shared.WeaponRemotes.Effects
local states={};local rng=Random.new()
local function get(player)
 if not states[player] then local spec=Config.Weapons.M4;states[player]={ammo=spec.Magazine,reserve=spec.Reserve,lastShot=-math.huge,reloadEnd=nil,tool=nil,serial=0,bucket={tokens=Config.RemoteBurst,updated=os.clock()}} end
 return states[player]
end
local function sync(player,s,hit,head,kill)
 State:FireClient(player,{id='M4',ammo=s.ammo,reserve=s.reserve,reloading=s.reloadEnd~=nil,reloadRemaining=s.reloadEnd and math.max(0,s.reloadEnd-os.clock()) or 0,hit=hit,headshot=head,kill=kill})
end
local function bindCharacter(player,character)
 local spec=Config.Weapons.M4;local s=get(player)
 s.serial+=1;s.ammo=spec.Magazine;s.reserve=spec.Reserve;s.reloadEnd=nil;s.tool=nil;s.lastShot=-math.huge
 character.ChildRemoved:Connect(function(child)
  if child==s.tool then s.serial+=1;s.reloadEnd=nil;s.tool=nil;sync(player,s) end
 end)
 local hum=character:WaitForChild('Humanoid',10)
 if hum then hum.Died:Connect(function() s.serial+=1;s.reloadEnd=nil;s.tool=nil;sync(player,s) end) end
end
local function added(player)
 get(player);player.CharacterAdded:Connect(function(c) bindCharacter(player,c) end)
 if player.Character then task.spawn(bindCharacter,player,player.Character) end
end
Players.PlayerAdded:Connect(added);for _,p in Players:GetPlayers() do added(p) end
Players.PlayerRemoving:Connect(function(p) states[p]=nil end)
Request.OnServerEvent:Connect(function(player,action,cameraOrigin,direction)
 local s=get(player);local now=os.clock()
 if not V.Consume(s.bucket,now,Config.RemoteBurst,Config.RemotePerSecond) then return end
 if action~='Sync' and action~='Reload' and action~='Fire' then return end
 local tool=V.Equipped(player);local character=V.Alive(player)
 if not tool or not character then return end
 s.tool=tool;local spec=Config.Weapons.M4
 if action=='Sync' then sync(player,s);return end
 if action=='Reload' then
  if s.reloadEnd or s.ammo>=spec.Magazine or s.reserve<=0 then sync(player,s);return end
  s.serial+=1;local serial=s.serial;s.reloadEnd=now+spec.ReloadTime;sync(player,s)
  task.delay(spec.ReloadTime,function()
   if states[player]~=s or s.serial~=serial then return end
   s.reloadEnd=nil
   if V.Equipped(player)==tool and V.Alive(player) then local n=math.min(spec.Magazine-s.ammo,s.reserve);s.ammo+=n;s.reserve-=n end
   sync(player,s)
  end)
  return
 end
 if s.reloadEnd or now-s.lastShot<spec.FireInterval-0.005 then return end
 if s.ammo<=0 then sync(player,s);return end
 local origin,dir,params=V.ValidateAim(player,tool,cameraOrigin,direction,spec)
 if not origin then return end
 s.lastShot=now;s.ammo-=1
 -- Spread and raycast are generated on the server; no client damage or hit target is accepted.
 local cone=math.rad(spec.SpreadDegrees);local radius=math.sqrt(rng:NextNumber())*math.tan(cone);local angle=rng:NextNumber()*math.pi*2
 dir=(CFrame.lookAt(Vector3.zero,dir)*Vector3.new(math.cos(angle)*radius,math.sin(angle)*radius,-1)).Unit
 local result=workspace:Raycast(origin,dir*spec.Range,params)
 local finish=result and result.Position or origin+dir*spec.Range
 local hit,head,kill=Damage.Apply(player,result,spec)
 sync(player,s,hit,head,kill)
 local material=result and result.Material.Name or ''
 -- Nearby clients only: bound replication cost for distant battles.
 for _,viewer in Players:GetPlayers() do
  local root=viewer.Character and viewer.Character:FindFirstChild('HumanoidRootPart')
  if viewer==player or root and (root.Position-origin).Magnitude<800 then Effects:FireClient(viewer,origin,finish,material,result and result.Normal) end
 end
end)
