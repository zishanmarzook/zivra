-- ZIVRA PHASE 1 M4 INSTALLER. Paste the COMPLETE Install-M4.luau into
-- Studio's Command Bar in Edit mode. Do not run this header separately.
assert(not game:GetService('RunService'):IsRunning(),'Stop Play before installing')
local ownedAttribute='ZIVRAWeaponOwned'
local replacements={
 {game.ReplicatedStorage,'ZIVRAWeapons'},
 {game.ServerScriptService,'ZIVRAWeapons'},
 {game.StarterPlayer.StarterPlayerScripts,'ZIVRAWeaponClient'},
 {game.StarterGui,'ZIVRAWeaponHUD'},
 {game.StarterPack,'ZIVRA_M4'},
}
for _,entry in replacements do
 local existing=entry[1]:FindFirstChild(entry[2])
 assert(not existing or existing:GetAttribute(ownedAttribute),'Existing unowned object: '..entry[2])
end
local history=game:GetService('ChangeHistoryService')
local recording=history:TryBeginRecording('Install ZIVRA Phase 1 M4')
local backup=Instance.new('Folder');backup.Name='ZIVRAWeaponBackup_'..os.time();backup.Parent=game.ServerStorage
for _,entry in replacements do
 local existing=entry[1]:FindFirstChild(entry[2])
 if existing then existing.Parent=backup;if existing:IsA('BaseScript') then existing.Enabled=false end end
end
local function object(class,name,parent)
 local item=Instance.new(class);item.Name=name;item:SetAttribute(ownedAttribute,true);item.Parent=parent;return item
end
local shared=object('Folder','ZIVRAWeapons',game.ReplicatedStorage)
local server=object('Folder','ZIVRAWeapons',game.ServerScriptService)
local remotes=object('Folder','WeaponRemotes',shared)
for _,name in ipairs({'Request','State','Effects'}) do object('RemoteEvent',name,remotes) end
local hud=object('ScreenGui','ZIVRAWeaponHUD',game.StarterGui);hud.ResetOnSpawn=false;hud.Enabled=false;hud.DisplayOrder=10
local sources={}

sources["WeaponConfig"] = [====[
-- ReplicatedStorage.ZIVRAWeapons.WeaponConfig
local Config = {}
Config.Version = 1
Config.RemoteBurst = 35
Config.RemotePerSecond = 20
Config.FriendlyFire = false
Config.Weapons = {
 M4 = {
  DisplayName = 'M4 // PROTOTYPE', Automatic = true,
  Magazine = 30, Reserve = 120, FireInterval = 0.1, ReloadTime = 2.2,
  Damage = 24, HeadMultiplier = 1.75, Range = 600,
  SpreadDegrees = 0.6, MaxCameraDistance = 32,
 },
}
-- Audio is intentionally omitted until permitted asset IDs are supplied.
return Config

]====]
sources["WeaponValidation"] = [====[
-- ServerScriptService.ZIVRAWeapons.WeaponValidation
local V = {}
function V.FiniteVector(v)
 if typeof(v) ~= 'Vector3' then return false end
 for _,n in ipairs({v.X,v.Y,v.Z}) do
  if n ~= n or math.abs(n) > 1e7 then return false end
 end
 return true
end
function V.Consume(bucket, now, burst, rate)
 bucket.tokens = math.min(burst, bucket.tokens + math.max(0,now-bucket.updated)*rate)
 bucket.updated = now
 if bucket.tokens < 1 then return false end
 bucket.tokens -= 1
 return true
end
function V.Alive(player)
 local c=player.Character
 local h=c and c:FindFirstChildOfClass('Humanoid')
 local root=c and c:FindFirstChild('HumanoidRootPart')
 if not h or h.Health<=0 or not root then return nil end
 return c,h,root
end
function V.Equipped(player)
 local c=player.Character
 if not c then return nil end
 for _,t in c:GetChildren() do
  if t:IsA('Tool') and t:GetAttribute('ZIVRAWeaponId') == 'M4' and t:GetAttribute('ZIVRAWeaponOwned') then return t end
 end
 return nil
end
function V.ValidateAim(player, tool, cameraOrigin, direction, spec)
 if not V.FiniteVector(cameraOrigin) or not V.FiniteVector(direction) then return nil end
 local length=direction.Magnitude
 if length<0.99 or length>1.01 then return nil end
 local character,_,root=V.Alive(player)
 if not character or tool.Parent~=character then return nil end
 local head=character:FindFirstChild('Head')
 if not head or (cameraOrigin-head.Position).Magnitude>spec.MaxCameraDistance then return nil end
 local handle=tool:FindFirstChild('Handle')
 local muzzle=handle and handle:FindFirstChild('Muzzle')
 if not muzzle or not muzzle:IsA('Attachment') then return nil end
 local origin=muzzle.WorldPosition
 if (origin-root.Position).Magnitude>9 then return nil end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character};params.RespectCanCollide=true
 -- A gun poking through a wall must not fire from its far side.
 local path=origin-head.Position
 if path.Magnitude>0.01 and workspace:Raycast(head.Position,path,params) then return nil end
 -- Reject third-person cameras positioned through world geometry.
 local cameraPath=cameraOrigin-head.Position
 if cameraPath.Magnitude>1 and workspace:Raycast(head.Position,cameraPath,params) then return nil end
 local aimHit=workspace:Raycast(cameraOrigin,direction.Unit*spec.Range,params)
 local target=aimHit and aimHit.Position or cameraOrigin+direction.Unit*spec.Range
 local delta=target-origin
 if delta.Magnitude<0.05 then return nil end
 return origin,delta.Unit,params
end
return V

]====]
sources["DamageService"] = [====[
-- ServerScriptService.ZIVRAWeapons.DamageService
local Players=game:GetService('Players')
local Config=require(game.ReplicatedStorage.ZIVRAWeapons.WeaponConfig)
local Damage={}
local function inside(cf,size,point)
 local p=cf:PointToObjectSpace(point);local s=size/2
 return math.abs(p.X)<=s.X and math.abs(p.Y)<=s.Y and math.abs(p.Z)<=s.Z
end
function Damage.InLobby(point)
 -- Lobby protection wins even when a combat zone overlaps it.
 for _,name in ipairs({'ZIVRA_Corridor','ZIVRA_Lobby'}) do
  local model=workspace:FindFirstChild(name)
  if model and model:IsA('Model') and model:FindFirstChildWhichIsA('BasePart',true) then
   local cf,size=model:GetBoundingBox()
   if inside(cf,size+Vector3.new(8,12,8),point) then return true end
  end
 end
 return false
end
function Damage.Zone(point)
 if Damage.InLobby(point) then return nil end
 local zones=workspace:FindFirstChild('ZIVRACombatZones')
 if not zones then return nil end
 for _,zone in zones:GetChildren() do
  if zone:IsA('BasePart') and zone:GetAttribute('Enabled')==true and inside(zone.CFrame,zone.Size,point) then return zone end
 end
 return nil
end
function Damage.Apply(shooter, result, spec)
 if not result then return false,false,false end
 local model=result.Instance:FindFirstAncestorOfClass('Model')
 while model and not model:FindFirstChildOfClass('Humanoid') do model=model.Parent and model.Parent:FindFirstAncestorOfClass('Model') end
 local hum=model and model:FindFirstChildOfClass('Humanoid')
 local root=model and model:FindFirstChild('HumanoidRootPart')
 local own=shooter.Character
 local ownRoot=own and own:FindFirstChild('HumanoidRootPart')
 if not hum or hum.Health<=0 or not root or not ownRoot or model==own then return false,false,false end
 if model:FindFirstChildOfClass('ForceField') then return false,false,false end
 local zone=Damage.Zone(ownRoot.Position)
 if not zone or Damage.Zone(root.Position)~=zone or Damage.Zone(result.Position)~=zone then return false,false,false end
 local victim=Players:GetPlayerFromCharacter(model)
 if victim and not Config.FriendlyFire and not shooter.Neutral and not victim.Neutral and shooter.Team~=nil and shooter.Team==victim.Team then return false,false,false end
 local head=result.Instance.Name=='Head'
 local before=hum.Health
 hum:TakeDamage(spec.Damage*(head and spec.HeadMultiplier or 1))
 return hum.Health<before,head,hum.Health<=0
end
return Damage

]====]
sources["WeaponServer"] = [====[
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

]====]
sources["WeaponClient"] = [====[
-- StarterPlayer.StarterPlayerScripts.ZIVRAWeaponClient
local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local RunService=game:GetService('RunService')
local TweenService=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local player=Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('ZIVRAWeapons')
local Config=require(shared.WeaponConfig)
local spec=Config.Weapons.M4
local remotes=shared.WeaponRemotes
local gui=player:WaitForChild('PlayerGui'):WaitForChild('ZIVRAWeaponHUD')
local equipped,holding=false,false
local fireGeneration=0
local ammo,reserve,reloading=spec.Magazine,spec.Reserve,false
local reloadEnd=0
local toolConnections={}
local function label(name,text,size,pos,fontSize)
 local t=Instance.new('TextLabel');t.Name=name;t.Text=text;t.Size=size;t.Position=pos;t.BackgroundTransparency=1;t.TextColor3=Color3.fromRGB(224,235,255);t.Font=Enum.Font.GothamBold;t.TextSize=fontSize;t.TextWrapped=true;t.Parent=gui;return t
end
local panel=Instance.new('Frame');panel.Name='AmmoPanel';panel.AnchorPoint=Vector2.new(1,1);panel.Position=UDim2.new(1,-16,1,-90);panel.Size=UDim2.new(0.34,0,0,100);panel.BackgroundColor3=Color3.fromRGB(18,20,31);panel.BackgroundTransparency=0.12;panel.Parent=gui
local constraint=Instance.new('UISizeConstraint');constraint.MaxSize=Vector2.new(290,100);constraint.Parent=panel
local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,12);corner.Parent=panel
local stroke=Instance.new('UIStroke');stroke.Color=Color3.fromRGB(160,76,245);stroke.Transparency=0.3;stroke.Parent=panel
local name=label('WeaponName',spec.DisplayName,UDim2.new(1,-16,0,24),UDim2.fromOffset(8,5),13);name.Parent=panel
local ammoText=label('Ammo','30 / 120',UDim2.new(1,-16,0,32),UDim2.fromOffset(8,29),24);ammoText.Parent=panel
local status=label('Status','R / RELOAD',UDim2.new(1,-16,0,24),UDim2.fromOffset(8,65),11);status.Parent=panel
local bar=Instance.new('Frame');bar.Name='ReloadProgress';bar.Position=UDim2.new(0,8,1,-5);bar.Size=UDim2.new(0,0,0,2);bar.BackgroundColor3=Color3.fromRGB(255,218,65);bar.BorderSizePixel=0;bar.Parent=panel
local cross=label('Crosshair','+',UDim2.fromOffset(28,28),UDim2.new(0.5,-14,0.5,-14),25)
local hit=label('Hitmarker','×',UDim2.fromOffset(40,40),UDim2.new(0.5,-20,0.5,-20),34);hit.Visible=false
local notice=label('Confirmation','',UDim2.new(0.6,0,0,30),UDim2.new(0.2,0,0.5,34),15)
local function button(name,text,pos)
 local b=Instance.new('TextButton');b.Name=name;b.Text=text;b.Position=pos;b.Size=UDim2.fromOffset(64,54);b.BackgroundColor3=Color3.fromRGB(34,31,56);b.BackgroundTransparency=0.2;b.TextColor3=Color3.fromRGB(238,232,255);b.TextSize=14;b.Font=Enum.Font.GothamBold;b.Parent=gui
 local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,12);c.Parent=b;return b
end
local shoot=button('Shoot','FIRE',UDim2.new(1,-94,0.5,-24))
local reload=button('Reload','RELOAD',UDim2.new(1,-168,0.5,40))
local function refresh()
 gui.Enabled=equipped
 ammoText.Text=string.format('%02d / %03d',ammo,reserve)
 status.Text=reloading and 'RELOADING' or ammo==0 and 'EMPTY // RELOAD' or 'R / RELOAD'
 shoot.Visible=UIS.TouchEnabled;reload.Visible=true
 -- Preserve the lobby HUD's visibility choice rather than modifying its controller.
 cross.Visible=equipped
end
local function requestReload() if equipped then holding=false;remotes.Request:FireServer('Reload') end end
reload.Activated:Connect(requestReload)
local function startFire()
 if holding or not equipped then return end;holding=true;fireGeneration+=1;local generation=fireGeneration
 task.spawn(function()
  while holding and equipped and generation==fireGeneration do
   if ammo>0 and not reloading then
    local camera=workspace.CurrentCamera
    if camera then local size=camera.ViewportSize;local ray=camera:ViewportPointToRay(size.X/2,size.Y/2);remotes.Request:FireServer('Fire',ray.Origin,ray.Direction.Unit) end
   end
   task.wait(spec.FireInterval+0.005)
  end
 end)
end
shoot.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then startFire() end end)
shoot.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then holding=false end end)
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.R then requestReload() end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then holding=false end end)
UIS.WindowFocusReleased:Connect(function() holding=false end)
local function watchTool(tool)
 if not tool:IsA('Tool') or tool:GetAttribute('ZIVRAWeaponId')~='M4' or toolConnections[tool] then return end
 toolConnections[tool]=true
 tool.Equipped:Connect(function() equipped=true;holding=false;remotes.Request:FireServer('Sync');refresh() end)
 tool.Unequipped:Connect(function() equipped=false;holding=false;refresh() end)
 tool.Activated:Connect(startFire)
 tool.Deactivated:Connect(function() holding=false end)
 tool.Destroying:Connect(function() toolConnections[tool]=nil end)
 if tool.Parent==player.Character then equipped=true;remotes.Request:FireServer('Sync');refresh() end
end
local function characterAdded(character)
 equipped=false;holding=false;refresh()
 for _,tool in character:GetChildren() do watchTool(tool) end
 character.ChildAdded:Connect(watchTool)
 local hum=character:WaitForChild('Humanoid');hum.Died:Connect(function() equipped=false;holding=false;refresh() end)
end
local backpack=player:WaitForChild('Backpack');for _,tool in backpack:GetChildren() do watchTool(tool) end;backpack.ChildAdded:Connect(watchTool)
player.CharacterAdded:Connect(characterAdded);if player.Character then characterAdded(player.Character) end
local confirmationSerial=0
remotes.State.OnClientEvent:Connect(function(state)
 ammo=state.ammo;reserve=state.reserve;reloading=state.reloading;reloadEnd=os.clock()+(state.reloadRemaining or 0)
 if state.hit then
  confirmationSerial+=1;local serial=confirmationSerial
  hit.Visible=true;hit.TextColor3=state.headshot and Color3.fromRGB(255,215,70) or Color3.new(1,1,1)
  notice.Text=state.kill and 'ELIMINATION' or state.headshot and 'HEADSHOT' or ''
  task.delay(0.2,function() if serial==confirmationSerial then hit.Visible=false end end)
  task.delay(1.5,function() if serial==confirmationSerial then notice.Text='' end end)
 end
 refresh()
end)
RunService.RenderStepped:Connect(function()
 if not equipped then return end
 bar.Size=UDim2.new(reloading and math.clamp(1-(reloadEnd-os.clock())/spec.ReloadTime,0,1) or 0,-0,0,2)
end)
local effectsFolder=Instance.new('Folder');effectsFolder.Name='ZIVRALocalWeaponFX';effectsFolder.Parent=workspace
remotes.Effects.OnClientEvent:Connect(function(origin,finish,material,normal)
 local distance=(finish-origin).Magnitude
 if distance>0.01 then
  local p=Instance.new('Part');p.Name='Tracer';p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(255,222,105);p.Size=Vector3.new(0.055,0.055,distance);p.CFrame=CFrame.lookAt((origin+finish)/2,finish);p.Parent=effectsFolder;TweenService:Create(p,TweenInfo.new(0.09),{Transparency=1}):Play();Debris:AddItem(p,0.12)
 end
 local flash=Instance.new('Part');flash.Name='MuzzleFlash';flash.Shape=Enum.PartType.Ball;flash.Size=Vector3.new(0.25,0.25,0.4);flash.Position=origin;flash.Anchored=true;flash.CanCollide=false;flash.CanTouch=false;flash.CanQuery=false;flash.CastShadow=false;flash.Material=Enum.Material.Neon;flash.Color=Color3.fromRGB(255,221,136);flash.Parent=effectsFolder;Debris:AddItem(flash,0.05)
 if normal then
  local marker=Instance.new('Part');marker.Name='Impact';marker.Anchored=true;marker.CanCollide=false;marker.CanTouch=false;marker.CanQuery=false;marker.CastShadow=false;marker.Size=Vector3.new(0.13,0.13,0.13);marker.Position=finish+normal*0.03
  marker.Color=(material=='Metal' or material=='DiamondPlate' or material=='CorrodedMetal') and Color3.fromRGB(255,208,87) or material=='Concrete' and Color3.fromRGB(168,164,155) or Color3.fromRGB(186,202,217)
  marker.Material=Enum.Material.Neon;marker.Parent=effectsFolder;Debris:AddItem(marker,0.18)
 end
end)
refresh()

]====]
local function source(class,name,parent,key)
 local s=Instance.new(class);s.Name=name;s.Source=sources[key];s:SetAttribute(ownedAttribute,true);s.Parent=parent;return s
end
source('ModuleScript','WeaponConfig',shared,'WeaponConfig')
source('ModuleScript','WeaponValidation',server,'WeaponValidation')
source('ModuleScript','DamageService',server,'DamageService')
source('Script','WeaponServer',server,'WeaponServer')
source('LocalScript','ZIVRAWeaponClient',game.StarterPlayer.StarterPlayerScripts,'WeaponClient')
local tool=object('Tool','ZIVRA_M4',game.StarterPack)
tool.ToolTip='M4 Phase 1 prototype | R: reload | hold click: fire'
tool.CanBeDropped=false;tool:SetAttribute('ZIVRAWeaponId','M4')
tool.Grip=CFrame.new(0,-0.25,0.7)
local function gunPart(name,size,cf,color)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Metal;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Parent=tool;return p
end
local black=Color3.fromRGB(35,39,49)
local handle=gunPart('Handle',Vector3.new(0.48,0.6,1.9),CFrame.new(),black)
local function add(name,size,cf,color)
 local p=gunPart(name,size,cf,color or black);local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=p;weld.Parent=p;return p
end
add('Barrel',Vector3.new(0.18,0.18,1.4),CFrame.new(0,0.1,-1.6),Color3.fromRGB(90,96,106))
add('Stock',Vector3.new(0.42,0.5,1.1),CFrame.new(0,0,1.4))
add('Grip',Vector3.new(0.35,0.7,0.4),CFrame.new(0,-0.55,0.4)*CFrame.Angles(math.rad(-15),0,0))
add('Magazine',Vector3.new(0.35,0.95,0.55),CFrame.new(0,-0.7,-0.35)*CFrame.Angles(math.rad(8),0,0))
add('Sight',Vector3.new(0.2,0.26,0.3),CFrame.new(0,0.42,-0.4),Color3.fromRGB(108,85,168))
add('TriggerArea',Vector3.new(0.16,0.16,0.45),CFrame.new(0,-0.4,0.1),Color3.fromRGB(108,112,124))
local muzzle=Instance.new('Attachment');muzzle.Name='Muzzle';muzzle.Position=Vector3.new(0,0.1,-2.35);muzzle.Parent=handle
local zones=workspace:FindFirstChild('ZIVRACombatZones')
if not zones then zones=object('Folder','ZIVRACombatZones',workspace) end
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
print('ZIVRA Phase 1 installed: M4 prototype. No combat zones enabled. Lobby remains protected. Press Play and equip slot 1.')

