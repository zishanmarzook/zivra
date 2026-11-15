-- Generated selective update for the audited ZIVRA place. No geometry changes.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before applying")
assert(game.PlaceId==121932020544473,"This patch targets the audited ZIVRA place")
local entries={
{path=[=[
ReplicatedStorage.ZIVRA.Theme]=],beforeBytes=455,beforeHash=1709397169,after=[=[
-- Shared combat and headquarters design tokens.
return { Background=Color3.fromRGB(12,16,23), Surface=Color3.fromRGB(22,29,39),
 Raised=Color3.fromRGB(34,44,57), Line=Color3.fromRGB(68,85,103), Text=Color3.fromRGB(242,246,250),
 Muted=Color3.fromRGB(163,179,196), Blue=Color3.fromRGB(36,131,220), Cyan=Color3.fromRGB(64,190,219),
 Purple=Color3.fromRGB(145,160,189), Gold=Color3.fromRGB(232,176,81), Green=Color3.fromRGB(108,190,153),
 Red=Color3.fromRGB(235,92,95), Font=Enum.Font.Gotham, Bold=Enum.Font.GothamBold,
 Spacing={Small=8,Medium=16,Large=24}, Radius=5, Transition=0.16 }
]=]},
{path=[=[
ReplicatedStorage.ZIVRAHQ.UIComponents]=],beforeBytes=2365,beforeHash=48182408,after=[=[
local Tween=game:GetService('TweenService')
local T=require(game.ReplicatedStorage.ZIVRA.Theme)
local U={Colors={BG=T.Background,Panel=T.Surface,Raised=T.Raised,Accent=T.Blue,Cyan=T.Cyan,Text=T.Text,White=T.Text,Muted=T.Muted}}

function U.Frame(parent,name,size,pos,color)
 local f=Instance.new('Frame');f.Name=name;f.Size=size;f.Position=pos or UDim2.new();f.BackgroundColor3=color or U.Colors.Panel;f.BorderSizePixel=0;f.Parent=parent;return f
end
function U.Text(parent,text,size,pos,fontSize,color)
 local t=Instance.new('TextLabel');t.Size=size;t.Position=pos or UDim2.new();t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or U.Colors.Text;t.TextSize=fontSize or 15;t.Font=Enum.Font.Gotham;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextWrapped=true;t.Parent=parent;return t
end
function U.Button(parent,text,size,pos,callback,primary)
 local b=Instance.new('TextButton');b.Name=text;b.Text=text;b.Size=size;b.Position=pos or UDim2.new();b.BackgroundColor3=primary and U.Colors.Accent or U.Colors.Raised;b.BorderSizePixel=0;b.TextColor3=U.Colors.Text;b.Font=Enum.Font.GothamBold;b.TextSize=14;b.TextWrapped=true;b.AutoButtonColor=false;b.Selectable=true;b.Parent=parent
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,T.Radius);corner.Parent=b
 local outline=Instance.new('UIStroke');outline.Color=U.Colors.Cyan;outline.Transparency=1;outline.Parent=b
 local function highlight(on) Tween:Create(outline,TweenInfo.new(T.Transition),{Transparency=on and 0.1 or 1}):Play() end
 b.MouseEnter:Connect(function() highlight(true) end);b.MouseLeave:Connect(function() highlight(false) end)
 b.SelectionGained:Connect(function() highlight(true) end);b.SelectionLost:Connect(function() highlight(false) end)
 b.Activated:Connect(callback);return b
end
function U.List(parent)
 local s=Instance.new('ScrollingFrame');s.Name='Content';s.BackgroundTransparency=1;s.BorderSizePixel=0;s.Size=UDim2.fromScale(1,1);s.ScrollBarThickness=4;s.AutomaticCanvasSize=Enum.AutomaticSize.Y;s.CanvasSize=UDim2.new();s.Parent=parent
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,9);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=s
 local pad=Instance.new('UIPadding');pad.PaddingRight=UDim.new(0,8);pad.Parent=s
 return s
end
return U]=]},
{path=[=[
StarterPlayer.StarterPlayerScripts.ZIVRAHQClient]=],beforeBytes=18203,beforeHash=320998063,after=[=[
local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Tween=game:GetService('TweenService')
local Run=game:GetService('RunService')
local GuiService=game:GetService('GuiService')
local p=Players.LocalPlayer
local Shared=game.ReplicatedStorage:WaitForChild('ZIVRAHQ')
local Config=require(Shared.Config);local U=require(Shared.UIComponents);local Remote=Shared.Request
local modes={};for _,v in Config.Modes do modes[v.Id]=v end
local gui=Instance.new('ScreenGui');gui.Name='ZIVRAHeadquarters';gui.ResetOnSpawn=false;gui.DisplayOrder=15;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=p:WaitForChild('PlayerGui')
local header=U.Frame(gui,'Header',UDim2.new(1,-32,0,58),UDim2.fromOffset(16,10),U.Colors.BG)
local brand=U.Text(header,'Z I V R A',UDim2.new(0.4,0,0,28),UDim2.fromOffset(16,3),23);brand.Font=Enum.Font.GothamBold
local status=U.Text(header,'HEADQUARTERS / CONNECTING',UDim2.new(0.5,0,0,17),UDim2.fromOffset(16,33),11,U.Colors.Cyan)
local avatar=Instance.new('ImageLabel');avatar.Size=UDim2.fromOffset(42,42);avatar.Position=UDim2.new(1,-210,0,8);avatar.BackgroundTransparency=1;avatar.Parent=header
local identity=U.Text(header,p.DisplayName,UDim2.fromOffset(156,24),UDim2.new(1,-160,0,6),14)
local level=U.Text(header,'SESSION PROFILE',UDim2.fromOffset(156,18),UDim2.new(1,-160,0,31),11,U.Colors.Muted)
task.spawn(function() local ok,url=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end);if ok then avatar.Image=url end end)
local shell=U.Frame(gui,'Menu',UDim2.new(1,-32,1,-158),UDim2.fromOffset(16,82),U.Colors.BG)
shell.BackgroundTransparency=0.04
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
local function open(value)
 if p:GetAttribute('ZIVRACombatMenu') or (p:GetAttribute('ZIVRACombatMode') and p:GetAttribute('ZIVRACombatMode')~='Lobby') then value=false end
 opened=value;shell.Visible=value
 p.CameraMode=Enum.CameraMode.LockFirstPerson
 UIS.MouseBehavior=value and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
 if value then
  local top=shell:GetAttribute('Top') or 82
  shell.Position=UDim2.fromOffset(16,top+8);Tween:Create(shell,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{Position=UDim2.fromOffset(16,top)}):Play()
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
 if page=='Play' then
  local quick=row(54)
  U.Button(quick,'READY / NOT READY',UDim2.new(0.49,0,1,-10),UDim2.fromOffset(5,5),function() send('Ready') end)
  U.Button(quick,state and state.party.status=='Searching' and 'CANCEL QUEUE' or 'FIND MATCH',UDim2.new(0.49,-5,1,-10),UDim2.new(0.51,0,0,5),function() send(state and state.party.status=='Searching' and 'Cancel' or 'Queue') end,true)
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
for i,name in {'Play','Loadout','Career','Missions','Friends','Leaderboards','Settings','Training'} do
 local b=U.Button(nav,string.upper(name),UDim2.new(1,-16,0,42),UDim2.fromOffset(8,12+(i-1)*48),function() page=name;render() end)
 navButtons[name]=b
end
local function layout()
 local size=workspace.CurrentCamera.ViewportSize;local mobile=size.X<800 or size.Y<550
 local navWidth=mobile and 112 or 148
 local top=mobile and 60 or 82;shell:SetAttribute('Top',top);shell.Position=UDim2.fromOffset(16,top);shell.Size=UDim2.new(1,-32,1,mobile and -124 or -158)
 header.Size=UDim2.new(1,-32,0,mobile and 42 or 58);brand.TextSize=mobile and 18 or 23;status.Position=UDim2.fromOffset(16,mobile and 25 or 33);status.TextSize=mobile and 9 or 11
 nav.Size=UDim2.new(0,navWidth,1,0);content.Position=UDim2.fromOffset(navWidth+16,mobile and 40 or 55);content.Size=UDim2.new(1,-navWidth-30,1,mobile and -48 or -66);heading.Position=UDim2.fromOffset(navWidth+16,8)
 for i,name in {'Play','Loadout','Career','Missions','Friends','Leaderboards','Settings','Training'} do local b=navButtons[name];b.Size=UDim2.new(1,-12,0,42);b.Position=UDim2.fromOffset(6,8+(i-1)*48);b.TextSize=mobile and 11 or 13 end
 avatar.Visible=not mobile;identity.Visible=not mobile;level.Visible=not mobile
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
  local movement=require(game.ReplicatedStorage.ZIVRAMovement.Config)
  movement.MotionScale=settings.ReducedMotion and 0 or 1
  movement.BaseFOV=settings.FOV;movement.SprintFOV=settings.FOV+7;movement.AutoSprint=settings.AutoSprint
  p:SetAttribute('ZIVRASettingAutoSprint',settings.AutoSprint)
  if p:GetAttribute('ZIVRAAppliedFOV')~=settings.FOV then workspace.CurrentCamera.FieldOfView=settings.FOV;p:SetAttribute('ZIVRAAppliedFOV',settings.FOV) end
  level.Text='LV '..data.profile.Level..'  /  SESSION XP '..data.profile.XP
  status.Text=data.party.status=='InMatch' and 'MATCH ASSIGNED' or data.training and 'TRAINING / LIVE FIRE' or 'HEADQUARTERS / '..data.party.status:upper()
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
 render();open(true)
end)
task.spawn(function()
 while gui.Parent do
  if state then
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
]=]},
{path=[=[
StarterPlayer.StarterPlayerScripts.ZIVRA_Client]=],beforeBytes=10487,beforeHash=1292869945,after=[=[
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local Shared=game.ReplicatedStorage:WaitForChild("ZIVRA")
local request=Shared:WaitForChild("Request")
local feedback=Shared:WaitForChild("Feedback")
local Weapons=require(Shared.Weapons)
local UI=require(script.UI)
local Effects=require(script.Effects)
local VM=require(script.Viewmodel)
local state,held,fireTouch,chargeStart
local cameraRecoil=CFrame.identity
local nextFire=0; local burstToken=0; local sprint=false; local aim=false
local originalCameraMode=player.CameraMode
local originalFOV=workspace.CurrentCamera.FieldOfView
local originalSensitivity=UIS.MouseDeltaSensitivity
local function send(action,value) request:FireServer(action,value) end
local function direction()
	local cam=workspace.CurrentCamera; local size=cam.ViewportSize
	return cam:ViewportPointToRay(size.X/2,size.Y/2).Direction.Unit
end
local function stop()
	held=false; fireTouch=nil; chargeStart=nil; VM.charge=0; VM.firing=false; burstToken+=1; send("Trigger",false)
end
local function usable()
	local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	return state and state.mode~="Lobby" and not UI.menu and not UI.editing and not GuiService.MenuIsOpen and not UIS:GetFocusedTextBox() and h and h.Health>0
end
local function predict(d)
	VM.fire()
	if d.magazine then Effects.pulse((workspace.CurrentCamera.CFrame*CFrame.new(0.4,-0.25,-2)).Position,Color3.fromRGB(255,190,80),0.25,0.05) end
end
local function shoot()
	if not usable() then return end
	local d=Weapons.ById[state.loadout[state.slot]]
	if d.magazine and (state.ammo[d.id] or 0)<=0 then return end
	send("Fire",direction()); predict(d); nextFire=os.clock()+d.interval
end
local function fire(on,input)
	if on then
		if not usable() or held then return end
		held=true; fireTouch=input and input.UserInputType==Enum.UserInputType.Touch and input or nil
		VM.firing=true; chargeStart=os.clock(); send("Trigger",true)
		local d=Weapons.ById[state.loadout[state.slot]]
		if d.kind=="charge" then return end
		if d.kind=="burst" then
			burstToken+=1; local token=burstToken
			task.spawn(function()
				for _=1,3 do
					if token~=burstToken or not usable() then break end
					shoot(); task.wait(d.interval+0.01)
				end
			end)
		elseif not d.spinup then shoot() end
	else
		if held and usable() then
			local d=Weapons.ById[state.loadout[state.slot]]
			if d.kind=="charge" then send("Release",direction()); predict(d) end
		end
		held=false; fireTouch=nil; chargeStart=nil; VM.charge=0; VM.firing=false; send("Trigger",false)
	end
end
local function action(name,on,input)
	if name=="Fire" then fire(on,input); return end
	if not usable() then return end
	if name=="Alt" then
		local d=Weapons.ById[state.loadout[state.slot]]
		if d.slash or d.shield or d.warp or d.charge or d.kind=="satchel" or d.kind=="grapple" then
			if on then send("Alt",direction()); if d.charge then stop() end end
		else aim=on; VM.aim=on end
	elseif on and name=="Reload" then stop(); send("Reload")
	elseif on and name=="Utility" then send("Utility",direction())
	elseif on and name=="Crouch" then send("Crouch")
	elseif name=="Sprint" then
		if UIS.TouchEnabled then if on then sprint=not sprint; send("Sprint",sprint) end
		else sprint=on; send("Sprint",on) end
	end
end
local nativeMenuState
local function nativeControls(open)
 local touchGui=player.PlayerGui:FindFirstChild("TouchGui")
 if open and not nativeMenuState then
  nativeMenuState={backpack=game:GetService("StarterGui"):GetCoreGuiEnabled(Enum.CoreGuiType.Backpack),touch=touchGui and touchGui.Enabled}
  game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
  if touchGui then touchGui.Enabled=false end
 elseif not open and nativeMenuState then
  game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,nativeMenuState.backpack)
  if touchGui and nativeMenuState.touch~=nil then touchGui.Enabled=nativeMenuState.touch end
  nativeMenuState=nil
 end
end
UI.init(send,function(open)
 nativeControls(open)
    if UI.gui then UI.gui.Enabled=open or (state and state.mode~="Lobby") or false end
	stop(); aim=false; VM.aim=false; send("Menu",open)
	UIS.MouseBehavior=open and Enum.MouseBehavior.Default or (state and state.mode~="Lobby" and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default)
	player:SetAttribute("ZIVRACombatMenu",open)
    if open then workspace.CurrentCamera.FieldOfView=originalFOV end
end,action)
-- Modal text button releases first-person mouse lock while menus are open.
UI.equip.Modal=true
UI.gui.Enabled=false
local opener=Instance.new("BindableEvent");opener.Name="ZIVRA_OpenLoadout";opener.Parent=player.PlayerScripts
opener.Event:Connect(function() UI.setMenu(true,"Weapons") end)
local settingsOpener=Instance.new("BindableEvent");settingsOpener.Name="ZIVRA_OpenSettings";settingsOpener.Parent=player.PlayerScripts
settingsOpener.Event:Connect(function() UI.setMenu(true,"Settings") end)
local mapping={Fire={Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2},Alt={Enum.UserInputType.MouseButton2,Enum.KeyCode.ButtonL2},
	Reload={Enum.KeyCode.R,Enum.KeyCode.ButtonX},Utility={Enum.KeyCode.G,Enum.KeyCode.ButtonR1},
	Crouch={Enum.KeyCode.C,Enum.KeyCode.LeftControl,Enum.KeyCode.ButtonB},Sprint={Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3}}
for name,keys in pairs(mapping) do
	CAS:BindAction("ZIVRACombat_"..name,function(_,inputState,input)
		if UIS:GetFocusedTextBox() or UI.menu or UI.editing or not state or state.mode=="Lobby" then return Enum.ContextActionResult.Pass end
		if inputState==Enum.UserInputState.Begin then action(name,true,input)
		elseif inputState==Enum.UserInputState.End or inputState==Enum.UserInputState.Cancel then action(name,false,input) end
		return Enum.ContextActionResult.Sink
	end,false,table.unpack(keys))
end
CAS:BindAction("ZIVRACombat_Menu",function(_,inputState)
	if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if inputState==Enum.UserInputState.Begin then UI.setMenu(not UI.menu) end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.B,Enum.KeyCode.ButtonY)
CAS:BindAction("ZIVRACombat_Back",function(_,inputState)
 if not UI.menu then return Enum.ContextActionResult.Pass end
 if inputState==Enum.UserInputState.Begin then UI.setMenu(false) end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.ButtonB)
for i,key in ipairs({Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four}) do
	CAS:BindAction("ZIVRACombat_Slot"..i,function(_,inputState)
		if not usable() then return Enum.ContextActionResult.Pass end
		if inputState==Enum.UserInputState.Begin then stop(); send("Equip",state.loadout[i]) end
		return Enum.ContextActionResult.Sink
	end,false,key,({Enum.KeyCode.DPadUp,Enum.KeyCode.DPadRight,Enum.KeyCode.DPadDown,Enum.KeyCode.DPadLeft})[i])
end
CAS:BindAction("ZIVRACombat_Inspect",function(_,inputState)
	if not usable() then return Enum.ContextActionResult.Pass end
	if inputState==Enum.UserInputState.Begin then VM.inspectUntil=os.clock()+1.4 end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.F,Enum.KeyCode.ButtonL1)
UIS.TouchMoved:Connect(function(input)
	if input~=fireTouch or not held or UI.menu then return end
	local delta=input.Delta; local cam=workspace.CurrentCamera
	local pitch,yaw=cam.CFrame:ToOrientation(); local sensitivity=(UI.settings.sensitivity or 1)*0.004
	pitch=math.clamp(pitch-delta.Y*sensitivity,-1.4,1.4); yaw-=delta.X*sensitivity
	cam.CFrame=CFrame.new(cam.CFrame.Position)*CFrame.fromOrientation(pitch,yaw,0)
end)
UIS.WindowFocusReleased:Connect(function() stop(); sprint=false; aim=false; VM.aim=false; send("Sprint",false) end)
player.CharacterAdded:Connect(function() stop(); VM.reloadStart=nil; aim=false; UI.setMenu(false) end)
feedback.OnClientEvent:Connect(function(kind,data)
	if kind=="State" then
		if state and state.mode~=data.mode and UI.menu then UI.setMenu(false) end
		local changed=not state or state.slot~=data.slot or state.loadout[data.slot]~=data.loadout[data.slot] or state.mode~=data.mode
		if changed then stop(); VM.reloadStart=nil; aim=false; VM.aim=false end
		state=data; UI.update(data)
        UI.gui.Enabled=data.mode~="Lobby" or UI.menu
        UI.nav.Visible=false
        UI.inviteButton.Visible=false
        UI.health.Visible=data.mode~="Lobby";UI.ammo.Visible=data.mode~="Lobby"
        UI.top.Visible=data.mode~="Lobby";UI.currency.Visible=data.mode~="Lobby"
        UI.menuButton.Visible=data.mode~="Lobby"
        if data.mode~="Lobby" or UI.menu then UI.gui.Enabled=true end
		VM.equip(data.loadout[data.slot]); VM.visible=data.mode~="Lobby"
		if data.mode~="Lobby" then player.CameraMode=Enum.CameraMode.LockFirstPerson end
		UIS.MouseDeltaSensitivity=originalSensitivity*(data.settings.sensitivity or 1)
		Effects.quality=data.settings.quality; Effects.volume=data.settings.volume
	elseif kind=="Effect" then Effects.play(data.kind,data.data)
	elseif kind=="Fired" then
		local d=Weapons.ById[data.id]
		Effects.audio(d,"fire",workspace.CurrentCamera.CFrame.Position)
		if d.slot==4 or data.slash then VM.fire() end
	elseif kind=="Hit" then UI.hitUntil=os.clock()+0.13; UI.hit.TextColor3=data.headshot and Color3.fromRGB(255,211,38) or Color3.new(1,1,1)
	elseif kind=="Reload" then VM.reload(data.duration)
	elseif kind=="Healing" then VM.reload(data.duration); UI.notice("Healing - taking damage interrupts")
	elseif kind=="Hurt" then
		UI.healthText.TextColor3=Color3.fromRGB(255,65,75)
		task.delay(0.15,function() UI.healthText.TextColor3=Color3.fromRGB(16,17,22) end)
	elseif kind=="Flash" then UI.flashScreen(data.intensity,data.duration)
	elseif kind=="Distort" then UI.flashScreen(0.15,data.duration)
	elseif kind=="Slide" then VM.landing=0.2
	elseif kind=="Invite" then
		UI.inviteText.Text=data.name.." invited you to a duel."; UI.invitationUntil=os.clock()+data.duration
		UI.notice("Duel invitation from "..data.name.." - open INVITE")
	elseif kind=="Notice" then UI.notice(data) end
end)
GuiService.MenuOpened:Connect(function() stop(); send("Menu",true) end)
GuiService.MenuClosed:Connect(function() send("Menu",UI.menu) end)
RunService:BindToRenderStep("ZIVRA_RemoveRecoil",Enum.RenderPriority.Camera.Value-1,function()
	workspace.CurrentCamera.CFrame*=cameraRecoil:Inverse(); cameraRecoil=CFrame.identity
end)
RunService:BindToRenderStep("ZIVRA_Viewmodel",Enum.RenderPriority.Camera.Value+1,function(dt)
	local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if held and usable() then
		local d=Weapons.ById[state.loadout[state.slot]]
		if d.charge then VM.charge=math.clamp((os.clock()-(chargeStart or os.clock()))/d.charge,0,1)
		elseif d.kind=="auto" or d.automatic or d.continuous or d.kind=="flame" then
			if os.clock()>=nextFire and (not d.spinup or os.clock()-(chargeStart or os.clock())>=d.spinup) then shoot() end
		end
	end
	local cam=workspace.CurrentCamera
	if state and state.mode~="Lobby" then cam.FieldOfView+=( (aim and not UI.menu and originalFOV-12 or originalFOV)-cam.FieldOfView)*math.min(1,dt*12) end
	cameraRecoil=usable() and CFrame.Angles(VM.kick*0.12,0,0) or CFrame.identity
	cam.CFrame*=cameraRecoil
	VM.step(dt,h,UI.menu)
	local d=state and Weapons.ById[state.loadout[state.slot]]
	local spread=5+(d and d.spread or 0)+VM.kick*30+(h and h.MoveDirection.Magnitude*3 or 0)
	if aim then spread*=0.65 end
	if d and d.charge then spread=10-VM.charge*7 end
	UI.step(h,spread)
end)
send("Sync")
-- Loading a profile may finish after client bootstrap.
task.spawn(function() while not state do task.wait(2); send("Sync") end end)
]=]},
{path=[=[
StarterPlayer.StarterPlayerScripts.ZIVRA_Client.UI]=],beforeBytes=25745,beforeHash=1884418629,after=[=[
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local GuiService=game:GetService("GuiService")
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Models=require(game.ReplicatedStorage.ZIVRA.Models)
local T=require(game.ReplicatedStorage.ZIVRA.Theme)
local UI={category=1,selected={},menu=false,cards={},tabPreviews={},touch={},settings={},hudLayout={}}
local function make(class,parent,props)
	local x=Instance.new(class)
	for k,v in pairs(props or {}) do x[k]=v end
	x.Parent=parent; return x
end
local function round(x,r) make("UICorner",x,{CornerRadius=UDim.new(0,r or 6)}) end
local function stroke(x,color,width) return make("UIStroke",x,{Color=color or T.Line,Thickness=width or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function label(parent,text,size,pos,dim,color)
	return make("TextLabel",parent,{BackgroundTransparency=1,Text=text,TextColor3=color or T.Text,Font=T.Font,TextSize=size,
		TextXAlignment=Enum.TextXAlignment.Left,Position=pos or UDim2.new(),Size=dim or UDim2.fromScale(1,1),TextTruncate=Enum.TextTruncate.AtEnd})
end
local function button(parent,text,pos,dim,fn)
	if dim.Y.Scale==0 and dim.Y.Offset>0 then dim=UDim2.new(dim.X.Scale,dim.X.Offset,0,math.max(44,dim.Y.Offset)) end
	local b=make("TextButton",parent,{Text=text,TextSize=13,Font=T.Bold,TextColor3=T.Text,BackgroundColor3=T.Raised,
		AutoButtonColor=false,Position=pos,Size=dim,BorderSizePixel=0})
	round(b,6); stroke(b)
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(50,54,66)}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=T.Raised}):Play() end)
	if fn then b.Activated:Connect(fn) end
	return b
end
local function viewport(parent,d,pos,size)
	local v=make("ViewportFrame",parent,{BackgroundTransparency=1,Position=pos,Size=size,Ambient=Color3.fromRGB(180,185,200),LightColor=Color3.new(1,0.95,0.85),LightDirection=Vector3.new(-1,-2,-2)})
	local world=make("WorldModel",v); local m=Models.build(d,false); m.Parent=world
	local cf,ext=m:GetBoundingBox(); local length=math.max(ext.X,ext.Y,ext.Z)
	local cam=make("Camera",v,{FieldOfView=32}); cam.CFrame=CFrame.lookAt(cf.Position+Vector3.new(1,0.5,-1.4).Unit*length*2,cf.Position)
	v.CurrentCamera=cam; return v
end
function UI.notice(text)
	UI.toast.Text=text; UI.toast.Visible=true; UI.toastUntil=os.clock()+3
end
function UI.setMenu(open,screen)
	if open and not UI.state then UI.notice("Loading profile..."); return end
	UI.menu=open; UI.overlay.Visible=open; UI.onMenu(open)
	UI.touchLayer.Visible=not open and UIS.TouchEnabled and UI.state and UI.state.mode~="Lobby"
	UI.reticle.Visible=not open and UI.state and UI.state.mode~="Lobby"
	TweenService:Create(UI.blur,TweenInfo.new(0.18),{Size=open and UI.settings.quality~="Low" and 14 or 0}):Play()
	UI.weaponPanel.Visible=open and (screen==nil or screen=="Weapons")
	UI.options.Visible=open and screen=="Settings"; UI.tasks.Visible=open and screen=="Tasks"
	UI.invites.Visible=open and screen=="Invites"
	if UI.invites.Visible then UI.rebuildInvites() end
	if open and UI.weaponPanel.Visible then UI.rebuild() end
	if UIS.GamepadEnabled then GuiService.SelectedObject=open and (UI.options.Visible and UI.qualityButton or UI.equip) or nil end
end
function UI.rebuildInvites()
	for _,x in ipairs(UI.playerList:GetChildren()) do if x:IsA("GuiObject") then x:Destroy() end end
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=Players.LocalPlayer then
			button(UI.playerList,p.DisplayName.."  /  INVITE",UDim2.new(),UDim2.new(1,-8,0,40),function() UI.send("Invite",p.UserId) end)
		end
	end
end
function UI.rebuild()
	if not UI.state then return end
	for _,x in ipairs(UI.grid:GetChildren()) do if x:IsA("GuiObject") then x:Destroy() end end
	UI.cards={}
	for i,b in ipairs(UI.tabs) do
		b.UIStroke.Color=i==UI.category and T.Text or T.Line; b.UIStroke.Thickness=i==UI.category and 2 or 1
	end
	local valid={}
	for _,d in ipairs(Weapons.List) do if d.slot==UI.category and (UI.state.mode=="Range" or UI.state.owned[d.id]) then table.insert(valid,d) end end
	local random=button(UI.grid,"RANDOM",UDim2.new(),UDim2.new(),function()
		if #valid==0 then return end
		local choices={}; for _,d in ipairs(valid) do if d.id~=UI.state.loadout[UI.category] then table.insert(choices,d) end end
		if #choices==0 then choices=valid end
		UI.choose(choices[math.random(#choices)].id)
	end)
	random.BackgroundColor3=Color3.fromRGB(10,11,15); random.LayoutOrder=0
	label(random,"/  /",30,UDim2.fromScale(0.15,0.12),UDim2.fromScale(0.7,0.45),T.Muted).TextXAlignment=Enum.TextXAlignment.Center
	for order,d in ipairs(Weapons.List) do
		if d.slot==UI.category then
			local b=button(UI.grid,"",UDim2.new(),UDim2.new(),function() UI.choose(d.id) end); b.LayoutOrder=order
			if d.rarity=="Signature" then b.UIStroke.Color=T.Gold end
			viewport(b,d,UDim2.fromScale(0,-0.03),UDim2.fromScale(1,0.78))
			label(b,d.name,13,UDim2.fromScale(0.07,0.72),UDim2.fromScale(0.88,0.18)).Font=T.Bold
			local owned=UI.state.owned[d.id]
			local status=UI.state.loadout[d.slot]==d.id and "EQUIPPED" or not owned and (UI.state.mode=="Range" and "TRIAL" or "LOCKED") or "OWNED"
			label(b,status,10,UDim2.fromScale(0.07,0.9),UDim2.fromScale(0.88,0.1),status=="EQUIPPED" and T.Cyan or T.Muted)
			UI.cards[d.id]=b
		end
	end
	UI.highlight()
end
function UI.highlight()
	local id=UI.selected[UI.category] or UI.state.loadout[UI.category]
	for key,b in pairs(UI.cards) do b.UIStroke.Thickness=key==id and 2 or 1; b.UIStroke.Color=key==id and T.Text or T.Line end
	local d=Weapons.ById[id]; if not d then return end
	UI.detail.Text=d.name.."  /  "..d.kind:upper().."  /  "..(d.magazine and tostring(d.magazine).." ROUNDS" or d.heal and "HEAL "..d.heal or tostring(d.damage).." DAMAGE")
	UI.equip.Text=UI.state.mode=="Range" and "TRY WEAPON" or UI.state.owned[id] and "EQUIP" or "RANGE TRIAL ONLY"
end
function UI.choose(id)
	local d=Weapons.ById[id]; UI.selected[d.slot]=id; UI.highlight()
	if UI.state.mode=="Range" then UI.send("Equip",id) end
end
function UI.resize()
	local width=UI.grid.AbsoluteSize.X
	local columns=width>=600 and 5 or width>=420 and 4 or 3
	local size=math.floor((width-(columns-1)*8)/columns)
	UI.gridLayout.CellSize=UDim2.fromOffset(size,size); UI.gridLayout.CellPadding=UDim2.fromOffset(8,8)
	local phone=UI.root.AbsoluteSize.Y<500 or UI.root.AbsoluteSize.X<600
	UI.title.TextSize=phone and 15 or 20
	UI.subtitle.Visible=not phone
	UI.tabBar.Position=UDim2.fromOffset(0,phone and 40 or 64); UI.tabBar.Size=UDim2.new(1,0,0,phone and 62 or 86)
	for _,b in ipairs(UI.tabs) do b.Size=UDim2.fromOffset(phone and 62 or 86,phone and 62 or 86) end
	UI.ammo.Position=UDim2.new(0.5,-150,1,-94); UI.ammo.Size=UDim2.fromOffset(300,24); UI.ammo.TextXAlignment=Enum.TextXAlignment.Center
	UI.applyLayout()
	UI.grid.Position=UDim2.fromOffset(0,phone and 112 or 162); UI.grid.Size=UDim2.new(1,0,1,phone and -176 or -226)
end
local defaults={Fire={x=0.88,y=0.42,size=76},Reload={x=0.73,y=0.59,size=52},Alt={x=0.76,y=0.33,size=52},
	Utility={x=0.88,y=0.64,size=56},Crouch={x=0.64,y=0.68,size=52},Sprint={x=0.62,y=0.43,size=48}}
function UI.applyLayout()
	for id,b in pairs(UI.touch) do
		local p=UI.hudLayout[id] or defaults[id]
		local available=UI.root.AbsoluteSize
		local scale=math.min(1,available.X/640,available.Y/360)
		local size=math.max(44,p.size*scale)
		b.Position=UDim2.fromScale(p.x,p.y); b.Size=UDim2.fromOffset(size,size)
	end
end
local function touching(a,b)
	local pa,pb=a.AbsolutePosition,b.AbsolutePosition; local sa,sb=a.AbsoluteSize,b.AbsoluteSize
	return pa.X<pb.X+sb.X+6 and pa.X+sa.X+6>pb.X and pa.Y<pb.Y+sb.Y+6 and pa.Y+sa.Y+6>pb.Y
end
function UI.init(send,onMenu,action)
	UI.send=send; UI.onMenu=onMenu; UI.action=action
	local player=Players.LocalPlayer
	UI.gui=make("ScreenGui",player:WaitForChild("PlayerGui"),{Name="ZIVRA_UI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=20})
	UI.root=make("Frame",UI.gui,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
	UI.blur=make("BlurEffect",Lighting,{Name="ZIVRA_MenuBlur",Size=0})
	UI.top=label(UI.root,"ZIVRA  /  HEADQUARTERS",13,UDim2.fromOffset(16,8),UDim2.new(0.6,0,0,24)); UI.top.Font=T.Bold
	UI.currency=label(UI.root,"",13,UDim2.new(1,-220,0,8),UDim2.fromOffset(204,24),T.Gold); UI.currency.TextXAlignment=Enum.TextXAlignment.Right
	UI.toast=label(UI.root,"",14,UDim2.fromScale(0.25,0.17),UDim2.fromScale(0.5,0.08)); UI.toast.TextXAlignment=Enum.TextXAlignment.Center; UI.toast.TextWrapped=true; UI.toast.Visible=false; UI.toast.ZIndex=60
	UI.health=make("Frame",UI.root,{Position=UDim2.new(0,16,1,-42),Size=UDim2.fromOffset(160,24),BackgroundColor3=T.Background,BorderSizePixel=0}); round(UI.health,4)
	UI.healthFill=make("Frame",UI.health,{Size=UDim2.fromScale(1,1),BackgroundColor3=T.Green,BorderSizePixel=0}); round(UI.healthFill,4)
	UI.healthText=label(UI.health,"100",12,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),T.Background); UI.healthText.Font=T.Bold
	UI.ammo=label(UI.root,"",16,UDim2.new(1,-240,1,-42),UDim2.fromOffset(220,24)); UI.ammo.TextXAlignment=Enum.TextXAlignment.Right
	UI.reticle=make("Frame",UI.root,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(2,2),BackgroundColor3=T.Text,BorderSizePixel=0})
	UI.cross={}; for i=1,4 do UI.cross[i]=make("Frame",UI.reticle,{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(i<=2 and 6 or 2,i<=2 and 2 or 6),BackgroundColor3=T.Text,BorderSizePixel=0}) end
	UI.hit=label(UI.root,"X",26,UDim2.fromScale(0.5,0.5),UDim2.fromOffset(30,30)); UI.hit.AnchorPoint=Vector2.new(0.5,0.5); UI.hit.TextXAlignment=Enum.TextXAlignment.Center; UI.hit.Visible=false
	UI.nav=make("Frame",UI.root,{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-68),Size=UDim2.new(0.94,0,0,40),BackgroundTransparency=1})
	make("UISizeConstraint",UI.nav,{MaxSize=Vector2.new(720,40)})
	make("UIListLayout",UI.nav,{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,8)})
	local links={
		{"WEAPONS",function() UI.setMenu(true,"Weapons") end}, {"RANGE",function() send("Range") end},
		{"DUELS",function() send("Queue") end}, {"TASKS",function() UI.setMenu(true,"Tasks") end}, {"SETTINGS",function() UI.setMenu(true,"Settings") end}}
	for _,link in ipairs(links) do local b=button(UI.nav,link[1],UDim2.new(),UDim2.new(0.2,-8,1,0),link[2]); b.TextSize=11 end
	UI.returnButton=button(UI.root,"LOBBY",UDim2.fromOffset(16,44),UDim2.fromOffset(88,32),function() send("Lobby") end)
	UI.inviteButton=button(UI.root,"INVITE",UDim2.fromOffset(16,44),UDim2.fromOffset(88,32),function() UI.setMenu(true,"Invites") end)
	UI.resetButton=button(UI.root,"RESET RANGE",UDim2.fromOffset(112,44),UDim2.fromOffset(110,32),function() send("ResetRange") end)
	UI.menuButton=button(UI.root,"LOADOUT",UDim2.new(1,-104,0,44),UDim2.fromOffset(88,32),function() UI.setMenu(not UI.menu) end)
	UI.rangeStats=label(UI.root,"",11,UDim2.fromOffset(16,84),UDim2.fromOffset(280,36),T.Muted); UI.rangeStats.TextWrapped=true
	UI.quickbar=make("Frame",UI.root,{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-12),Size=UDim2.new(0.44,0,0,42),BackgroundTransparency=1})
	make("UIListLayout",UI.quickbar,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4)})
	UI.quick={}
	for i=1,4 do
		UI.quick[i]=button(UI.quickbar,tostring(i),UDim2.new(),UDim2.new(0.25,-3,1,0),function() if UI.state then send("Equip",UI.state.loadout[i]) end end)
		UI.quick[i].TextSize=10; UI.quick[i].TextWrapped=true
	end
	UI.touchLayer=make("Frame",UI.root,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=UIS.TouchEnabled})
	for id,p in pairs(defaults) do
		local b=button(UI.touchLayer,id:upper(),UDim2.fromScale(p.x,p.y),UDim2.fromOffset(p.size,p.size),nil)
		b.AnchorPoint=Vector2.new(0.5,0.5); b.BackgroundTransparency=0.3; b.TextSize=10; b.UICorner.CornerRadius=UDim.new(1,0); UI.touch[id]=b
		local active,dragStart,old
		b.InputBegan:Connect(function(input)
			if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			active=input
			if UI.editing then UI.selectedButton=id; dragStart=Vector2.new(input.Position.X,input.Position.Y); old=b.Position
			else action(id,true,input) end
		end)
		UIS.InputChanged:Connect(function(input)
			if UI.editing and active and (input==active or input.UserInputType==Enum.UserInputType.MouseMovement) then
				local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart; local size=UI.root.AbsoluteSize
				b.Position=UDim2.fromScale(math.clamp(old.X.Scale+delta.X/size.X,0.52,0.94),math.clamp(old.Y.Scale+delta.Y/size.Y,0.2,0.75))
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input~=active then return end
			if UI.editing then
				for other,c in pairs(UI.touch) do if id~=other and touching(b,c) then b.Position=old; UI.notice("Keep action buttons separated"); break end end
				UI.hudLayout[id]={x=b.Position.X.Scale,y=b.Position.Y.Scale,size=b.AbsoluteSize.X}
			else action(id,false,input) end
			active=nil
		end)
	end
	UI.editDone=button(UI.root,"SAVE HUD",UDim2.fromScale(0.42,0.1),UDim2.fromOffset(100,36),function()
		UI.editing=false; UI.editDone.Visible=false; UI.smaller.Visible=false; UI.larger.Visible=false; send("Settings",{hud=UI.hudLayout}); UI.notice("HUD layout saved")
	end); UI.editDone.Visible=false
	local function resizeSelected(delta)
		local id=UI.selectedButton or "Fire"; local b=UI.touch[id]; local old=b.Size
		local size=math.clamp(b.AbsoluteSize.X+delta,44,88); b.Size=UDim2.fromOffset(size,size)
		for other,c in pairs(UI.touch) do if other~=id and touching(b,c) then b.Size=old; UI.notice("That size overlaps another control"); return end end
		UI.hudLayout[id]={x=b.Position.X.Scale,y=b.Position.Y.Scale,size=size}
	end
	UI.smaller=button(UI.root,"SIZE -",UDim2.fromScale(0.2,0.1),UDim2.fromOffset(72,36),function() resizeSelected(-4) end)
	UI.larger=button(UI.root,"SIZE +",UDim2.fromScale(0.65,0.1),UDim2.fromOffset(72,36),function() resizeSelected(4) end)
	UI.smaller.Visible=false; UI.larger.Visible=false
	UI.overlay=make("Frame",UI.root,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(23,25,35),BackgroundTransparency=0.35,BorderSizePixel=0,Visible=false})
	make("TextButton",UI.overlay,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",Modal=true,AutoButtonColor=false})
	UI.weaponPanel=make("Frame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,8),Size=UDim2.new(0.86,0,1,-16),BackgroundTransparency=1})
	make("UISizeConstraint",UI.weaponPanel,{MaxSize=Vector2.new(1040,1400)})
	UI.title=label(UI.weaponPanel,"ZIVRA / WEAPON COLLECTION",20,UDim2.new(),UDim2.new(1,-40,0,28)); UI.title.Font=T.Bold
	UI.subtitle=label(UI.weaponPanel,"Test every weapon in the range. Keep your owned loadout for duels.",12,UDim2.fromOffset(0,30),UDim2.new(1,-40,0,22),T.Muted)
	button(UI.weaponPanel,"X",UDim2.new(1,-36,0,0),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.tabBar=make("Frame",UI.weaponPanel,{Position=UDim2.fromOffset(0,64),Size=UDim2.new(1,0,0,86),BackgroundTransparency=1})
	make("UIListLayout",UI.tabBar,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Center})
	UI.tabs={}
	for i,name in ipairs(Weapons.Categories) do
		local b=button(UI.tabBar,"",UDim2.new(),UDim2.new(0.25,-6,1,0),function() UI.category=i; UI.rebuild() end)
		label(b,name:upper(),11,UDim2.new(0,8,1,-20),UDim2.new(1,-16,0,18)); UI.tabs[i]=b
	end
	UI.grid=make("ScrollingFrame",UI.weaponPanel,{Position=UDim2.fromOffset(0,162),Size=UDim2.new(1,0,1,-226),BackgroundTransparency=1,BorderSizePixel=0,
		CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Muted,ScrollingDirection=Enum.ScrollingDirection.Y})
	UI.gridLayout=make("UIGridLayout",UI.grid,{SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
	UI.detail=label(UI.weaponPanel,"",12,UDim2.new(0,0,1,-54),UDim2.new(1,-190,0,46),T.Muted); UI.detail.TextWrapped=true
	UI.equip=button(UI.weaponPanel,"EQUIP",UDim2.new(1,-180,1,-50),UDim2.fromOffset(180,42),function()
		local id=UI.selected[UI.category] or UI.state.loadout[UI.category]
		if UI.state.mode=="Range" or UI.state.owned[id] then send("Equip",id) else UI.notice("Enter the range to try this locked item") end
	end)
	UI.options=make("ScrollingFrame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.82,0.88),BackgroundColor3=T.Surface,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,440),ScrollBarThickness=3,Visible=false})
	make("UISizeConstraint",UI.options,{MaxSize=Vector2.new(560,500)})
	label(UI.options,"SETTINGS",20,UDim2.fromOffset(20,16),UDim2.fromOffset(300,30)).Font=T.Bold
	button(UI.options,"X",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.qualityButton=button(UI.options,"VFX QUALITY",UDim2.fromOffset(20,64),UDim2.new(1,-40,0,40),function()
		local options={"Automatic","Low","Medium","High"}; local index=table.find(options,UI.settings.quality) or 1
		send("Settings",{quality=options[index%4+1]})
	end)
	UI.flashButton=button(UI.options,"REDUCED FLASH",UDim2.fromOffset(20,112),UDim2.new(1,-40,0,40),function() send("Settings",{reduceFlash=not UI.settings.reduceFlash}) end)
	UI.volumeLabel=label(UI.options,"",13,UDim2.fromOffset(20,168),UDim2.new(0.6,0,0,32))
	button(UI.options,"-",UDim2.new(1,-112,0,164),UDim2.fromOffset(40,36),function() send("Settings",{volume=(UI.settings.volume or 0.6)-0.1}) end)
	button(UI.options,"+",UDim2.new(1,-64,0,164),UDim2.fromOffset(40,36),function() send("Settings",{volume=(UI.settings.volume or 0.6)+0.1}) end)
	UI.sensitivityLabel=label(UI.options,"",13,UDim2.fromOffset(20,216),UDim2.new(0.6,0,0,32))
	button(UI.options,"-",UDim2.new(1,-112,0,212),UDim2.fromOffset(40,36),function() send("Settings",{sensitivity=(UI.settings.sensitivity or 1)-0.1}) end)
	button(UI.options,"+",UDim2.new(1,-64,0,212),UDim2.fromOffset(40,36),function() send("Settings",{sensitivity=(UI.settings.sensitivity or 1)+0.1}) end)
	button(UI.options,"MOVE TOUCH BUTTONS",UDim2.fromOffset(20,268),UDim2.new(1,-40,0,40),function()
		UI.setMenu(false); UI.editing=true; UI.editDone.Visible=true; UI.smaller.Visible=true; UI.larger.Visible=true; UI.touchLayer.Visible=true; UI.notice("Drag buttons, then save. Combat is paused locally.")
	end)
	button(UI.options,"RESET TOUCH LAYOUT",UDim2.fromOffset(20,316),UDim2.new(1,-40,0,40),function() UI.hudLayout={}; UI.applyLayout(); send("Settings",{hud={}}) end)
	label(UI.options,"Native Roblox joystick and jump remain available.\nPress B to open your loadout, R to reload, and G for utility.",11,UDim2.fromOffset(20,368),UDim2.new(1,-40,0,54),T.Muted).TextWrapped=true
	UI.tasks=make("Frame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.84,0.85),BackgroundColor3=T.Surface,BorderSizePixel=0,Visible=false})
	make("UISizeConstraint",UI.tasks,{MaxSize=Vector2.new(560,360)})
	label(UI.tasks,"DAILY TASKS",20,UDim2.fromOffset(20,16),UDim2.new(1,-80,0,30)).Font=T.Bold
	button(UI.tasks,"X",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.taskRows={}
	for i,taskDef in ipairs({{"duels","Play duels",3},{"kills","Eliminations",15},{"wins","Win duels",2}}) do
		local key,title,goal=table.unpack(taskDef)
		local row=make("Frame",UI.tasks,{Position=UDim2.new(0,20,0.2+(i-1)*0.25,0),Size=UDim2.new(1,-40,0.2,0),BackgroundTransparency=1})
		local text=label(row,title,13,UDim2.new(),UDim2.new(1,-130,0,24))
		local track=make("Frame",row,{Position=UDim2.new(0,0,1,-12),Size=UDim2.new(1,-130,0,4),BackgroundColor3=T.Raised,BorderSizePixel=0})
		local fill=make("Frame",track,{Size=UDim2.fromScale(0,1),BackgroundColor3=i==1 and T.Green or T.Blue,BorderSizePixel=0})
		local claim=button(row,"100 CREDITS",UDim2.new(1,-112,0,0),UDim2.fromOffset(112,38),function() send("Claim",key) end)
		UI.taskRows[key]={label=text,fill=fill,claim=claim,title=title,goal=goal}
	end
	UI.invites=make("Frame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.84,0.88),BackgroundColor3=T.Surface,BorderSizePixel=0,Visible=false})
	make("UISizeConstraint",UI.invites,{MaxSize=Vector2.new(560,430)})
	label(UI.invites,"DUEL INVITATIONS",20,UDim2.fromOffset(20,16),UDim2.new(1,-80,0,30)).Font=T.Bold
	button(UI.invites,"X",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.inviteText=label(UI.invites,"Invite another player in the lobby.",13,UDim2.fromOffset(20,56),UDim2.new(1,-40,0,40),T.Muted)
	button(UI.invites,"ACCEPT",UDim2.fromOffset(20,100),UDim2.new(0.5,-24,0,36),function() send("AcceptInvite"); UI.invitationUntil=0; UI.setMenu(false) end)
	button(UI.invites,"DECLINE",UDim2.new(0.5,4,0,100),UDim2.new(0.5,-24,0,36),function() send("DeclineInvite"); UI.invitationUntil=0; UI.setMenu(false) end)
	UI.playerList=make("ScrollingFrame",UI.invites,{Position=UDim2.fromOffset(20,148),Size=UDim2.new(1,-40,1,-164),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3})
	make("UIListLayout",UI.playerList,{Padding=UDim.new(0,8)})
	UI.flash=make("Frame",UI.root,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(130,143,158),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=50})
	UI.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(UI.resize)
	UI.grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(UI.resize)
	UI.resize(); UI.applyLayout()
end
function UI.update(state)
	local old=UI.state; UI.state=state; UI.settings=state.settings
	UI.top.Text="ZIVRA  /  "..state.mode:upper()..(state.queued and " / QUEUED" or "")
	UI.currency.Text=tostring(state.currency).." CREDITS"..(state.offline and " / UNSAVED" or "")
	UI.inviteButton.Visible=state.mode=="Lobby"; UI.nav.Visible=state.mode=="Lobby"; UI.returnButton.Visible=state.mode~="Lobby"; UI.resetButton.Visible=state.mode=="Range"
	UI.rangeStats.Visible=state.mode=="Range"; UI.reticle.Visible=state.mode~="Lobby" and not UI.menu
	UI.quickbar.Visible=state.mode~="Lobby"; UI.touchLayer.Visible=(UIS.TouchEnabled and state.mode~="Lobby" or UI.editing) and not UI.menu
	local d=Weapons.ById[state.loadout[state.slot]]
	UI.ammo.Text=d.name.."  "..(d.magazine and (state.ammo[d.id] or 0).." / "..(state.reserve[d.id] or 0) or d.charges and tostring(state.charges[d.id] or 0).." USES" or "")
	if state.busy>0.3 then UI.ammo.Text..="  ..." end
	if d.heatPerShot then UI.ammo.Text..=string.format("  HEAT %d%%",state.heat*100) end
	UI.ammo.TextColor3=d.magazine and (state.ammo[d.id] or 0)==0 and T.Red or T.Text
	for i,b in ipairs(UI.quick) do b.Text=i.."  "..Weapons.ById[state.loadout[i]].name; b.UIStroke.Color=i==state.slot and T.Text or T.Line end
	local rs=state.stats; local seconds=rs.started and math.max(1,state.serverTime-rs.started) or 1
	UI.rangeStats.Text=string.format("%d SHOTS   %d HITS   %.0f DAMAGE\n%.1f DAMAGE / SEC",rs.shots,rs.hits,rs.damage,rs.damage/seconds)
	UI.qualityButton.Text="VFX QUALITY  /  "..state.settings.quality:upper()
	UI.flashButton.Text="REDUCED FLASH  /  "..(state.settings.reduceFlash and "ON" or "OFF")
	UI.volumeLabel.Text=string.format("VOLUME  %d%%",math.floor(state.settings.volume*100+0.5))
	UI.sensitivityLabel.Text=string.format("AIM SENSITIVITY  %.1f",state.settings.sensitivity or 1)
	if not UI.editing then UI.hudLayout=state.settings.hud or {}; UI.applyLayout() end
	local cooldown=math.max(0,(state.cooldowns[state.loadout[4]] or 0)-state.serverTime)
	UI.touch.Utility.Text=cooldown>0 and string.format("%.1fs",cooldown) or "UTILITY"
	for key,row in pairs(UI.taskRows) do
		local value=state.daily[key]; row.label.Text=row.title.."  "..math.min(value,row.goal).." / "..row.goal
		row.fill.Size=UDim2.fromScale(math.min(1,value/row.goal),1); row.claim.Text=state.daily.claimed[key] and "CLAIMED" or "100 CREDITS"
		row.claim.TextColor3=value>=row.goal and T.Gold or T.Muted
	end
	for i,b in ipairs(UI.tabs) do
		local previous=UI.tabPreviews[i]
		if not previous or previous.id~=state.loadout[i] then
			if previous then previous.frame:Destroy() end
			UI.tabPreviews[i]={id=state.loadout[i],frame=viewport(b,Weapons.ById[state.loadout[i]],UDim2.fromScale(0.12,0),UDim2.fromScale(0.76,0.7))}
		end
	end
	local changed=not old or old.mode~=state.mode
	if old then for i=1,4 do if old.loadout[i]~=state.loadout[i] then changed=true end end end
	if UI.menu and UI.weaponPanel.Visible and changed then UI.rebuild() end
	if state.message then UI.notice(state.message) end
end
function UI.step(humanoid,spread)
	if humanoid then
		local ratio=humanoid.Health/math.max(1,humanoid.MaxHealth)
		UI.healthFill.Size=UI.healthFill.Size:Lerp(UDim2.fromScale(ratio,1),0.15)
		UI.healthFill.BackgroundColor3=ratio>0.5 and T.Green or ratio>0.25 and T.Gold or T.Red
		UI.healthText.Text=tostring(math.ceil(humanoid.Health))
	end
	UI.cross[1].Position=UDim2.fromOffset(-spread,0); UI.cross[2].Position=UDim2.fromOffset(spread,0)
	UI.cross[3].Position=UDim2.fromOffset(0,-spread); UI.cross[4].Position=UDim2.fromOffset(0,spread)
	UI.toast.Visible=os.clock()<(UI.toastUntil or 0)
	UI.hit.Visible=os.clock()<(UI.hitUntil or 0)
	if UI.invitationUntil and os.clock()>=UI.invitationUntil then UI.inviteText.Text="Invite another player in the lobby."; UI.invitationUntil=nil end
end
function UI.flashScreen(intensity,duration)
	UI.flash.BackgroundTransparency=1-math.clamp(intensity,0,1)*(UI.settings.reduceFlash and 0.25 or 0.65)
	TweenService:Create(UI.flash,TweenInfo.new(duration),{BackgroundTransparency=1}):Play()
end
return UI
]=]}
}
local function find(path)
 local x=game
 for name in string.gmatch(path,"[^.]+") do x=x:FindFirstChild(name);assert(x,"Missing "..path) end
 return x
end
local function unchanged(source,e)
 local h=0
 for i=1,#source do h=(h*31+string.byte(source,i))%2147483647 end
 return #source==e.beforeBytes and h==e.beforeHash
end
for _,e in ipairs(entries) do
 e.instance=find(e.path)
 assert(unchanged(e.instance.Source,e) or e.instance.Source==e.after,"Source changed since audit: "..e.path..". Reconcile before updating.")
end
local history=game:GetService("ChangeHistoryService")
local recording=history:TryBeginRecording("ZIVRAReviewedUIPatch")
local backup=Instance.new("Folder");backup.Name="ZIVRA_UI_Recovery_"..os.time();backup.Parent=game.ServerStorage
for _,e in ipairs(entries) do
 if e.instance.Source~=e.after then
  local clone=e.instance:Clone();clone:SetAttribute("OriginalPath",e.path)
  if clone:IsA("BaseScript") then clone.Enabled=false end
  clone.Parent=backup;e.instance.Source=e.after
 end
end
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
print("ZIVRA UI update applied. Play-test before saving. No live publication performed.")
