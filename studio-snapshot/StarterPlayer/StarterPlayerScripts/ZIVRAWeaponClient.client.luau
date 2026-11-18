if require(game:GetService('ReplicatedStorage'):WaitForChild('ZIVRA').Config).Launch1v1 then return end
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
local gui=player:WaitForChild('PlayerGui'):WaitForChild('ZIVRAWeaponHUD',20)
if not gui then warn('ZIVRA weapon HUD unavailable; rejoin to restore weapon controls.');return end
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
local hit=label('Hitmarker','Ã-',UDim2.fromOffset(40,40),UDim2.new(0.5,-20,0.5,-20),34);hit.Visible=false
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

