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
