local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Tween=game:GetService('TweenService')
local Run=game:GetService('RunService')
local GuiService=game:GetService('GuiService')
local p=Players.LocalPlayer
local combatShared=game.ReplicatedStorage:WaitForChild('ZIVRA')
local launch=require(combatShared.Config).Launch1v1
local pages=launch and {'Play','Loadout','Settings'} or {'Play','Loadout','Career','Missions','Friends','Leaderboards','Settings','Training'}
local Shared=game.ReplicatedStorage:WaitForChild('ZIVRAHQ')
local Config=require(Shared.Config);local U=require(Shared.UIComponents);local Remote=Shared.Request
local modes={};for _,v in Config.Modes do modes[v.Id]=v end
local gui=Instance.new('ScreenGui');gui.Name='ZIVRAHeadquarters';gui.ResetOnSpawn=false;gui.DisplayOrder=15;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=p:WaitForChild('PlayerGui')
local header=U.Frame(gui,'Header',UDim2.new(1,-32,0,58),UDim2.fromOffset(16,10),U.Colors.BG)
-- ForgeGUI sample: job a1a35325-3d24-4baa-b32d-1546d85fe1c8; approved personal Image.
local emblem=Instance.new('ImageLabel');emblem.Name='ZIVRAEmblem';emblem.BackgroundTransparency=1;emblem.Image='rbxassetid://129565854362406';emblem.ScaleType=Enum.ScaleType.Fit;emblem.Size=UDim2.fromOffset(48,48);emblem.Position=UDim2.fromOffset(8,5);emblem.Parent=header
local brand=U.Text(header,'Z I V R A',UDim2.new(0.4,0,0,28),UDim2.fromOffset(64,3),23);brand.Font=Enum.Font.GothamBold
local status=U.Text(header,'HEADQUARTERS / CONNECTING',UDim2.new(0.5,0,0,17),UDim2.fromOffset(64,33),11,U.Colors.Cyan)
local avatar=Instance.new('ImageLabel');avatar.Size=UDim2.fromOffset(42,42);avatar.Position=UDim2.new(1,-210,0,8);avatar.BackgroundTransparency=1;avatar.Parent=header
local identity=U.Text(header,p.DisplayName,UDim2.fromOffset(156,24),UDim2.new(1,-160,0,6),14)
local level=U.Text(header,'SESSION PROFILE',UDim2.fromOffset(156,18),UDim2.new(1,-160,0,31),11,U.Colors.Muted)
task.spawn(function() local ok,url=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end);if ok then avatar.Image=url end end)
local shell=U.Frame(gui,'Menu',UDim2.new(1,-32,1,-158),UDim2.fromOffset(16,82),U.Colors.BG)
shell.BackgroundTransparency=0.04;shell.Visible=false
local nav=Instance.new('ScrollingFrame');nav.Name='Navigation';nav.Size=UDim2.new(0,148,1,0);nav.BackgroundColor3=U.Colors.Panel;nav.BorderSizePixel=0;nav.ScrollBarThickness=3;nav.CanvasSize=UDim2.fromOffset(0,400);nav.Parent=shell
local content=U.Frame(shell,'Page',UDim2.new(1,-178,1,-66),UDim2.fromOffset(164,55),U.Colors.BG)
local heading=U.Text(shell,'PLAY',UDim2.new(1,-230,0,38),UDim2.fromOffset(164,8),23);heading.Font=Enum.Font.GothamBold
local close=U.Button(shell,'X',UDim2.fromOffset(44,44),UDim2.new(1,-48,0,7),function() end)
close.Modal=true
local footer=U.Frame(gui,'PartyBar',UDim2.new(1,-32,0,52),UDim2.new(0,16,1,-64),U.Colors.Panel)
local foot=U.Text(footer,'LOBBY / M TO OPEN MENU',UDim2.new(1,-200,1,0),UDim2.fromOffset(12,0),13)
local menuButton=U.Button(footer,'PLAY / MENU [M]',UDim2.fromOffset(150,36),UDim2.new(1,-162,0,8),function() end,true)
local toast=U.Text(gui,'',UDim2.new(0.7,0,0,50),UDim2.new(0.15,0,0,78),14);toast.BackgroundColor3=U.Colors.Raised;toast.BackgroundTransparency=0.04;toast.Visible=false;toast.ZIndex=40
local toastVersion=0
local function notice(text)
 toastVersion+=1;local serial=toastVersion;toast.Text=text;toast.Visible=true
 task.delay(6,function() if serial==toastVersion then toast.Visible=false end end)
end
local state=nil;local page='Play';local selectedMode='Duel';local opened=false;local list=nil;local previewConnection=nil;local render;local navButtons={}
local function send(action,value) Remote:FireServer(action,value) end
local nativeMenuState
local function nativeControls(value)
 local touch=p.PlayerGui:FindFirstChild('TouchGui')
 local core=game:GetService('StarterGui')
 if value and not nativeMenuState then
  nativeMenuState={backpack=core:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack),touch=touch and touch.Enabled,touchDevice=UIS.TouchEnabled}
  core:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
  if touch then touch.Enabled=false end
 elseif not value and nativeMenuState then
  core:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,nativeMenuState.backpack)
  if touch then
   if UIS.TouchEnabled~=nativeMenuState.touchDevice then touch.Enabled=UIS.TouchEnabled
   elseif nativeMenuState.touch~=nil then touch.Enabled=nativeMenuState.touch end
  end
  nativeMenuState=nil
 end
end
-- PlayerModule can enable or recreate touch controls after a menu opens.
local function watchTouch(touch)
 if touch.Name~='TouchGui' or not touch:IsA('ScreenGui') then return end
 local function keepModal()
  if opened and nativeMenuState and touch.Enabled then
   nativeMenuState.touch=true;touch.Enabled=false
  end
 end
 touch:GetPropertyChangedSignal('Enabled'):Connect(keepModal);keepModal()
end
for _,child in p.PlayerGui:GetChildren() do watchTouch(child) end
p.PlayerGui.ChildAdded:Connect(watchTouch)
local function open(value)
 if p:GetAttribute('ZIVRACombatMenu') or (p:GetAttribute('ZIVRACombatMode') and p:GetAttribute('ZIVRACombatMode')~='Lobby') then value=false end
 opened=value;shell.Visible=value;nativeControls(value)
 p.CameraMode=Enum.CameraMode.LockFirstPerson
 UIS.MouseBehavior=value and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
 if value then
  local top=shell:GetAttribute('Top') or 82
  if state and state.profile.Settings.ReducedMotion then shell.Position=UDim2.fromOffset(16,top) else shell.Position=UDim2.fromOffset(16,top+8);Tween:Create(shell,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{Position=UDim2.fromOffset(16,top)}):Play() end
  if UIS.GamepadEnabled then GuiService.SelectedObject=navButtons[page] end
 else GuiService.SelectedObject=nil end
end
close.Activated:Connect(function() open(false) end);menuButton.Activated:Connect(function() open(not opened) end)
local function row(height)
 local f=U.Frame(list,'Row',UDim2.new(1,0,0,height));return f
end
local function paragraph(text,height)
 local f=row(height or 60);U.Text(f,text,UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6),14,U.Colors.Muted);return f
end
local function action(text,callback,primary)
 return U.Button(list,text,UDim2.new(1,0,0,44),nil,callback,primary)
end
local function headquartersHero()
 local compact=workspace.CurrentCamera.ViewportSize.Y<550
 local hero=row(compact and 100 or 158);hero.Name='HeadquartersHero';hero.ClipsDescendants=true;hero.BackgroundColor3=U.Colors.Raised
 -- ForgeGUI key art, generation 2bd0efc7-91e8-4bcf-9306-5ba246dc98d8.
 local art=Instance.new('ImageLabel');art.Name='HeadquartersArtwork';art.BackgroundTransparency=1;art.Image='rbxassetid://78032110481735';art.ScaleType=Enum.ScaleType.Crop;art.Size=UDim2.fromScale(1,1);art.Parent=hero
 local shade=U.Frame(hero,'TextShade',UDim2.fromScale(1,1),nil,U.Colors.BG)
 local fade=Instance.new('UIGradient');fade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(0.55,0.35),NumberSequenceKeypoint.new(1,1)});fade.Parent=shade
 local stripe=U.Frame(hero,'Accent',UDim2.new(0,3,1,-28),UDim2.fromOffset(0,14),U.Colors.Cyan)
 local eyebrow=U.Text(hero,'ZIVRA / OPERATIONS',UDim2.new(0.68,-24,0,20),UDim2.fromOffset(16,compact and 10 or 24),10,U.Colors.Cyan)
 local title=U.Text(hero,'READY FOR THE NEXT ROUND',UDim2.new(0.68,-24,0,compact and 45 or 58),UDim2.fromOffset(16,compact and 29 or 48),compact and 15 or 24);title.Font=Enum.Font.GothamBold
 if not compact then U.Text(hero,'ONE ARENA. TWO PLAYERS. ONE WINNER.',UDim2.new(0.68,-24,0,32),UDim2.fromOffset(16,110),12,U.Colors.Muted) end
end
local function showParty()
 local party=state and state.party;if not party then paragraph('Loading party state...');return end
 paragraph('PARTY / '..#party.members..' OPERATIVE(S)    /    '..party.status..'\nEvery member must ready up. Matchmaking uses this server.',62)
 for _,member in party.members do
  local f=row(56)
  local label=member.name..(member.id==party.leader and '  / LEADER' or '')..'\n'..(member.ready and 'READY' or 'NOT READY')
  U.Text(f,label,UDim2.new(0.55,0,1,0),UDim2.fromOffset(12,0),13,member.ready and Color3.fromRGB(97,215,161) or U.Colors.Text)
  if p.UserId==party.leader and member.id~=p.UserId then
   U.Button(f,'LEAD',UDim2.new(0.2,-4,0,38),UDim2.new(0.57,0,0,9),function() send('Transfer',member.id) end)
   U.Button(f,'REMOVE',UDim2.new(0.21,-4,0,38),UDim2.new(0.78,0,0,9),function() send('Kick',member.id) end)
  end
 end
 action('TOGGLE READY',function() send('Ready') end,true)
 if p.UserId==party.leader then
  action(party.status=='Searching' and 'CANCEL MATCHMAKING' or 'FIND MATCH',function() send(party.status=='Searching' and 'Cancel' or 'Queue') end,true)
 end
end
local function weaponPreview()
 local source=Shared:FindFirstChild('WeaponPreview')
 if not source then paragraph('Weapon preview is unavailable. The live weapon remains usable.');return end
 local v=Instance.new('ViewportFrame');v.Name='WeaponInspection';v.Size=UDim2.new(1,0,0,185);v.BackgroundColor3=U.Colors.Raised;v.Ambient=Color3.fromRGB(180,197,220);v.LightColor=Color3.new(1,1,1);v.LightDirection=Vector3.new(-1,-1,-1);v.Parent=list
 local world=Instance.new('WorldModel');world.Parent=v
 local model=Instance.new('Model');model.Parent=world
 local copy=source:Clone()
 for _,child in copy:GetChildren() do child.Parent=model end;copy:Destroy()
 for _,part in model:GetDescendants() do if part:IsA('BasePart') then part.Anchored=true;part.CanCollide=false elseif part:IsA('LuaSourceContainer') then part:Destroy() end end
 local cf,size=model:GetBoundingBox();model:PivotTo(CFrame.new(-cf.Position)*model:GetPivot())
 local cam=Instance.new('Camera');cam.Parent=v;v.CurrentCamera=cam
 local angle,zoom,drag,last=1.1,math.max(size.Magnitude*0.65,4),false,nil
 v.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=true;last=input.Position end end)
 v.InputEnded:Connect(function() drag=false end)
 v.InputChanged:Connect(function(input)
  if input.UserInputType==Enum.UserInputType.MouseWheel then zoom=math.clamp(zoom-input.Position.Z,3,20)
  elseif drag and last then angle+=(input.Position.X-last.X)*0.012;last=input.Position end
 end)
 local t=0;previewConnection=Run.RenderStepped:Connect(function(dt)
  t+=dt;if t<1/30 then return end;local elapsed=t;t=0
  if not drag and not (state and state.profile.Settings.ReducedMotion) then angle+=elapsed*0.35 end
  cam.CFrame=CFrame.lookAt(Vector3.new(math.sin(angle)*zoom,zoom*0.25,math.cos(angle)*zoom),Vector3.zero)
 end)
end
render=function()
 if previewConnection then previewConnection:Disconnect();previewConnection=nil end
 for _,v in content:GetChildren() do v:Destroy() end;list=U.List(content);heading.Text=string.upper(page)
 for name,b in pairs(navButtons) do b.BackgroundColor3=name==page and U.Colors.Accent or U.Colors.Panel end
 if launch and page=='Play' then
  headquartersHero()
  local queued=p:GetAttribute('ZIVRAQueued')==true
  action(queued and 'CANCEL QUEUE' or 'PLAY 1V1',function()
   local request=combatShared:FindFirstChild('Request')
   if p:GetAttribute('ZIVRAReady') and request then request:FireServer('Queue')
   else notice('Connecting to 1V1 services') end
  end,true)
  if queued then paragraph('Waiting for an opponent',44) end
 elseif launch and page=='Loadout' then
  action('OPEN LOADOUT',function()
   open(false)
   local event=p.PlayerScripts:FindFirstChild('ZIVRA_OpenLoadout')
   if event then event:Fire() end
  end,true)
 elseif page=='Play' then
  local quick=row(54)
  U.Button(quick,'READY / NOT READY',UDim2.new(0.49,0,1,-10),UDim2.fromOffset(5,5),function() send('Ready') end)
  U.Button(quick,state and state.party.status=='Searching' and 'CANCEL QUEUE' or 'FIND MATCH',UDim2.new(0.49,-5,1,-10),UDim2.new(0.51,0,0,5),function() send(state and state.party.status=='Searching' and 'Cancel' or 'Queue') end,true)
  headquartersHero()
  paragraph('Selected: '..(modes[selectedMode] and modes[selectedMode].Name or selectedMode)..'  /  '..(state and state.party.status or 'Connecting')..'\nReady and party controls: FRIENDS. Available maps: Tileyard + Gridlock.',60)
  for _,mode in Config.Modes do
   local f=row(88)
   U.Text(f,mode.Name,UDim2.new(1,-124,0,26),UDim2.fromOffset(12,7),16,selectedMode==mode.Id and U.Colors.Cyan or U.Colors.Text)
   U.Text(f,mode.Description,UDim2.new(1,-124,0,42),UDim2.fromOffset(12,35),12,U.Colors.Muted)
   local button=U.Button(f,mode.Available and (selectedMode==mode.Id and 'SELECTED' or 'SELECT') or 'OFFLINE',UDim2.fromOffset(100,44),UDim2.new(1,-112,0,22),function()
    selectedMode=mode.Id
    if mode.Id=='Training' then page='Training';render()
    elseif mode.Available then send('Mode',mode.Id)
    else notice(mode.Description) end
   end,selectedMode==mode.Id);button:SetAttribute('ModeId',mode.Id)
  end
 elseif page=='Friends' then
  showParty()
  action('LEAVE PARTY',function() send('Leave') end)
  if state and state.party.leader==p.UserId then action('DISBAND PARTY',function() send('Disband') end) end
  if state and state.invite then
   paragraph('PARTY INVITATION / expires in '..math.max(0,math.ceil(state.invite.expires-workspace:GetServerTimeNow()))..'s')
   action('ACCEPT INVITATION',function() send('Accept') end,true);action('DECLINE',function() send('Decline') end)
  end
  paragraph('PLAYERS IN THIS SERVER\nInvites stay in this server. Roblox chat remains available.',56)
  for _,q in Players:GetPlayers() do if q~=p then action('INVITE '..q.DisplayName,function() send('Invite',q.UserId) end) end end
 elseif page=='Loadout' then
  local spec=require(game.ReplicatedStorage.ZIVRAWeapons.WeaponConfig).Weapons.M4
  paragraph('M4 / ASSAULT RIFLE\nAvailable equipment. Drag to rotate; scroll to zoom.',56);weaponPreview()
  paragraph(string.format('Damage %d   /   %d RPM   /   Magazine %d\nReload %.1fs   /   Range %d studs   /   Spread %.1f degrees',spec.Damage,60/spec.FireInterval,spec.Magazine,spec.ReloadTime,spec.Range,spec.SpreadDegrees),68)
  action('EQUIP M4',function() send('Equip','M4') end,true)
  action('LOADOUT / RIFLE, HANDGUN, KNIFE',function() open(false);local event=p.PlayerScripts:FindFirstChild('ZIVRA_OpenLoadout');if event then event:Fire() end end,true)
 elseif page=='Training' then
  paragraph('LIVE FIRE / PRACTICE RANGE\nTry Assault Rifle, Handgun and Knife. Range trials are temporary.',64)
  if state then local d=state.profile;paragraph(string.format('Shots %d    Hits %d    Targets %d\nAccuracy %.1f%%',d.Shots,d.Hits,d.Targets,d.Shots>0 and 100*d.Hits/d.Shots or 0),65) end
  action('ENTER RANGE',function() game.ReplicatedStorage.ZIVRA.Request:FireServer('Range');open(false) end,true)
  action('ORIGINAL LOBBY TRAINING',function() send('Training');open(false) end)
  action('RESET TRAINING STATS',function() send('ResetTraining') end)
  action('RETURN TO HEADQUARTERS',function() send('LeaveTraining');open(false) end)
 elseif page=='Career' then
  if state then local d=state.profile
   paragraph('OPERATIVE '..p.DisplayName..'\nSESSION ONLY / Progress is not saved between servers.',65)
   paragraph(string.format('Level %d   /   XP %d / %d\nMatches %d   /   Wins %d\nEliminations %d   /   Deaths %d   /   K/D %.2f\nWin rate %.0f%%   /   Playtime %dm',d.Level,d.XP,d.Level*500,d.Matches,d.Wins,d.Eliminations,d.Deaths,d.Eliminations/math.max(1,d.Deaths),d.Matches>0 and d.Wins/d.Matches*100 or 0,math.floor(d.PlaySeconds/60)),160)
  end
 elseif page=='Missions' then
  paragraph('SESSION MISSION / COMPLETE 3 MATCHES\nOnly valid completed competitive rounds count. Training does not count.',80)
  if state then paragraph(tostring(math.min(3,state.profile.Matches))..' / 3 completed   /   Reward: 100 session XP') end
  action(state and state.profile.Claimed and 'REWARD CLAIMED' or 'CLAIM REWARD',function() send('Claim') end,true)
 elseif page=='Leaderboards' then
  paragraph('THIS SERVER / SESSION RECORDS\nGlobal rankings are unavailable until persistent records are configured.',64)
  if state then for i,r in state.roster do paragraph(string.format('%02d   %s\n%d wins  /  %d eliminations',i,r.name,r.wins,r.kills),58) end end
 elseif page=='Settings' then
  action('COMBAT AUDIO / SENSITIVITY / HUD',function() open(false);local event=p.PlayerScripts:FindFirstChild('ZIVRA_OpenSettings');if event then event:Fire() end end,true)
  paragraph('CUSTOM GAME SETTINGS / THIS SESSION\nRoblox graphics, chat, voice and audio controls remain in the Roblox menu.',64)
  local settings=state and state.profile.Settings or {ReducedMotion=false,AutoSprint=false,FOV=74}
  action('REDUCED MOTION: '..(settings.ReducedMotion and 'ON' or 'OFF'),function() send('Setting',{key='ReducedMotion',value=not settings.ReducedMotion}) end)
  action('AUTO SPRINT: '..(settings.AutoSprint and 'ON' or 'OFF'),function() send('Setting',{key='AutoSprint',value=not settings.AutoSprint}) end)
  action('FIELD OF VIEW: '..settings.FOV..'  /  +5',function() send('Setting',{key='FOV',value=settings.FOV>=95 and 65 or settings.FOV+5}) end)
  paragraph('M / gamepad Y: menu. Shift: sprint. C/Ctrl: slide. Space: jump.\nNo lobby music is loaded; audio controls are hidden.',70)
 end
end
for i,name in pages do
 local b=U.Button(nav,string.upper(name),UDim2.new(1,-16,0,42),UDim2.fromOffset(8,12+(i-1)*48),function() page=name;render() end)
 navButtons[name]=b
end
local function layout()
 local size=workspace.CurrentCamera.ViewportSize;local mobile=size.X<800 or size.Y<550
 local navWidth=mobile and 112 or 148
 local top=mobile and 60 or 82;shell:SetAttribute('Top',top);shell.Position=UDim2.fromOffset(16,top);shell.Size=UDim2.new(1,-32,1,mobile and -124 or -158)
 header.Size=UDim2.new(1,-32,0,mobile and 42 or 58);brand.TextSize=mobile and 18 or 23;status.Position=UDim2.fromOffset(mobile and 54 or 64,mobile and 25 or 33);status.TextSize=mobile and 9 or 11
 nav.Size=UDim2.new(0,navWidth,1,0);content.Position=UDim2.fromOffset(navWidth+16,mobile and 40 or 55);content.Size=UDim2.new(1,-navWidth-30,1,mobile and -48 or -66);heading.Position=UDim2.fromOffset(navWidth+16,8)
 for i,name in pages do local b=navButtons[name];b.Size=UDim2.new(1,-12,0,44);b.Position=UDim2.fromOffset(6,8+(i-1)*48);b.TextSize=mobile and 11 or 13 end
 emblem.Size=UDim2.fromOffset(mobile and 36 or 48,mobile and 36 or 48);emblem.Position=UDim2.fromOffset(8,mobile and 3 or 5);brand.Position=UDim2.fromOffset(mobile and 54 or 64,3)
 avatar.Visible=not mobile;identity.Visible=not mobile;level.Visible=not mobile and not launch
end
workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(layout);layout()
CAS:BindActionAtPriority('ZIVRA_Menu',function(_,input)
 local combatMode=p:GetAttribute('ZIVRACombatMode')
 if p:GetAttribute('ZIVRACombatMenu') or combatMode and combatMode~='Lobby' then return Enum.ContextActionResult.Pass end
 if input==Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() then open(not opened) end
 return Enum.ContextActionResult.Sink
end,false,2200,Enum.KeyCode.M,Enum.KeyCode.ButtonY)
UIS.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.LeftAlt then UIS.MouseBehavior=Enum.MouseBehavior.Default;menuButton.Modal=true end
end)
UIS.InputEnded:Connect(function(input) if input.KeyCode==Enum.KeyCode.LeftAlt then menuButton.Modal=false end end)
p.CharacterAdded:Connect(function() open(false) end)
local loading=U.Frame(gui,'Loading',UDim2.fromScale(1,1),nil,U.Colors.BG);loading.ZIndex=50
local loadText=U.Text(loading,'Z I V R A\nPREPARING HEADQUARTERS',UDim2.fromScale(0.8,0.5),UDim2.fromScale(0.1,0.25),26,U.Colors.White);loadText.ZIndex=51
local gotState=false
Remote.OnClientEvent:Connect(function(kind,data)
 if kind=='State' then
  if state and data.revision<=state.revision then return end
  state=data;gotState=true;selectedMode=data.party.mode
  local settings=data.profile.Settings
  p:SetAttribute('ZIVRAReducedMotion',settings.ReducedMotion)
  local movement=require(game.ReplicatedStorage.ZIVRAMovement.Config)
  movement.MotionScale=settings.ReducedMotion and 0 or 1
  movement.BaseFOV=settings.FOV;movement.SprintFOV=settings.FOV+7;movement.AutoSprint=settings.AutoSprint
  p:SetAttribute('ZIVRASettingAutoSprint',settings.AutoSprint)
  if p:GetAttribute('ZIVRAAppliedFOV')~=settings.FOV then workspace.CurrentCamera.FieldOfView=settings.FOV;p:SetAttribute('ZIVRAAppliedFOV',settings.FOV) end
  level.Text='LV '..data.profile.Level..'  /  SESSION XP '..data.profile.XP
  if not launch then status.Text=data.party.status=='InMatch' and 'MATCH ASSIGNED' or data.training and 'TRAINING / LIVE FIRE' or 'HEADQUARTERS / '..data.party.status:upper() end
  if opened and page~='Loadout' then render() end
 elseif kind=='Notice' then notice(data)
 elseif kind=='Open' then page=data.page or 'Play';selectedMode=data.mode or selectedMode;render();open(true)
 elseif kind=='Result' then notice(data.message..'  /  +'..data.xp..' SESSION XP');page='Play';render();open(true)
 end
end)
game.ReplicatedStorage.ZIVRAMapShared.MapSelection.OnClientEvent:Connect(function(kind)
 if kind=='Vote' or kind=='Prepare' or kind=='Playing' then open(false);header.Visible=false;footer.Visible=false
 elseif kind=='Lobby' then header.Visible=true;footer.Visible=true end
end)
task.spawn(function()
 local hq=workspace:WaitForChild('ZIVRA_Corridor',20)
 if hq then loadText.Text='Z I V R A\nCONNECTING LOBBY SERVICES' else loadText.Text='HEADQUARTERS UNAVAILABLE / REJOIN TO RETRY' end
 send('Sync')
 local deadline=os.clock()+15
 repeat task.wait(0.1) until gotState or os.clock()>deadline
 loading:Destroy()
 if not gotState then notice('Lobby services unavailable. Reopen the menu to retry.');menuButton.Activated:Connect(function() send('Sync') end) end
 render();open(false)
end)
task.spawn(function()
 while gui.Parent do
  if launch then
   local queued=p:GetAttribute('ZIVRAQueued')
   foot.Text=queued and 'WAITING FOR AN OPPONENT' or 'ZIVRA  /  1V1'
  elseif state then
   local party=state.party;local elapsed=party.queuedAt and math.max(0,math.floor(workspace:GetServerTimeNow()-party.queuedAt)) or 0
   foot.Text=(modes[party.mode] and modes[party.mode].Name or party.mode)..'  /  '..#party.members..' IN PARTY  /  '..party.status..(party.status=='Searching' and ' '..elapsed..'s' or '')
  end
  task.wait(1)
 end
end)
local function combatVisibility()
 local mode=p:GetAttribute("ZIVRACombatMode")
 local active=mode and mode~="Lobby"
 gui.Enabled=not active and not p:GetAttribute("ZIVRACombatMenu")
 if not gui.Enabled then open(false) end
end
p:GetAttributeChangedSignal("ZIVRACombatMode"):Connect(combatVisibility)
p:GetAttributeChangedSignal("ZIVRACombatMenu"):Connect(combatVisibility)
combatVisibility()

if launch then
 p:GetAttributeChangedSignal('ZIVRAQueued'):Connect(function()
  local queued=p:GetAttribute('ZIVRAQueued')
  foot.Text=queued and 'WAITING FOR AN OPPONENT' or 'ZIVRA  /  1V1'
  status.Text=queued and 'MATCHMAKING' or 'HEADQUARTERS'
  if opened and page=='Play' then render() end
 end)
end
