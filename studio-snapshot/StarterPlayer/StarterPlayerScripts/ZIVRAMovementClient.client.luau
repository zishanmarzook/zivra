local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Shared=game.ReplicatedStorage:WaitForChild('ZIVRAMovement')
local C=require(Shared.Config)
local Movement=require(Shared.MovementController)
local Animation=require(Shared.AnimationController)
local player=Players.LocalPlayer
local function combatActive() local mode=player:GetAttribute('ZIVRACombatMode');return mode and mode~='Lobby' end
local controller=nil;local observers={};local generation=0
local function remove(character)
 local entry=observers[character]
 if entry then entry.animation:Destroy();observers[character]=nil end
end
local function observe(character)
 task.spawn(function()
  local h=character:WaitForChild('Humanoid',10)
  if not h or h.RigType~=Enum.HumanoidRigType.R15 or not character.Parent then return end
  if observers[character] then return end
  observers[character]={animation=Animation.new(character),h=h}
 end)
end
local function bindLocal(character)
 generation+=1;local serial=generation
 if controller then controller:Destroy();controller=nil end
 task.spawn(function()
  local new=Movement.new(character,Shared.Request)
  if serial~=generation or player.Character~=character then if new then new:Destroy() end;return end
  controller=new
 end)
end
local function watch(p)
 p.CharacterAdded:Connect(function(character) observe(character);if p==player then bindLocal(character) end end)
 p.CharacterRemoving:Connect(function(character)
  remove(character)
  if p==player then generation+=1;if controller then controller:Destroy();controller=nil end end
 end)
 if p.Character then observe(p.Character);if p==player then bindLocal(p.Character) end end
end
Players.PlayerAdded:Connect(watch)
for _,p in Players:GetPlayers() do watch(p) end
local function sprint(_,state,input)
 if combatActive() then return Enum.ContextActionResult.Pass end
 if controller then
  if input.UserInputType==Enum.UserInputType.Touch or input.KeyCode==Enum.KeyCode.ButtonL3 then
   if state==Enum.UserInputState.Begin then controller.sprint=not controller.sprint end
  else controller.sprint=state==Enum.UserInputState.Begin or state==Enum.UserInputState.Change end
 end
 return Enum.ContextActionResult.Sink
end
CAS:BindActionAtPriority('ZIVRA_Sprint',sprint,false,2100,table.unpack(C.SprintKeys))
CAS:BindActionAtPriority('ZIVRA_Slide',function(_,state)
 if combatActive() then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin and controller and not UIS:GetFocusedTextBox() then controller:SlideOrCrouch() end
 return Enum.ContextActionResult.Sink
end,false,2100,table.unpack(C.SlideKeys))
CAS:BindActionAtPriority('ZIVRA_Crouch',function(_,state)
 if combatActive() then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin and controller and not UIS:GetFocusedTextBox() then controller:EndSlide();controller.crouch=not controller.crouch end
 return Enum.ContextActionResult.Sink
end,false,2100,table.unpack(C.CrouchKeys))
CAS:BindAction('ZIVRA_Jump',function(_,state)
 if state==Enum.UserInputState.Begin and controller then controller:Jump();controller.h.Jump=true end
 return Enum.ContextActionResult.Sink
end,false)
-- Native Roblox mobile jump remains active and routes through JumpRequest.
-- Separate safe-area buttons avoid the native jump control and weapon HUD.
local touchGui=Instance.new('ScreenGui');touchGui.Name='ZIVRAMovementTouch'
touchGui.ResetOnSpawn=false;touchGui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets
touchGui.Enabled=UIS.TouchEnabled;touchGui.Parent=player:WaitForChild('PlayerGui')
local function touchButton(name,label,x,callback)
 local button=Instance.new('TextButton');button.Name=name;button.Text=label
 button.Position=UDim2.new(0,x,0.5,-22);button.Size=UDim2.fromOffset(72,48)
 button.BackgroundColor3=Color3.fromRGB(25,28,35);button.BackgroundTransparency=0.2
 button.TextColor3=Color3.new(1,1,1);button.Font=Enum.Font.GothamBold;button.TextSize=12
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,10);corner.Parent=button
 button.Modal=UIS.TouchEnabled
 button.Parent=touchGui;button.Activated:Connect(callback)
 return button
end
local sprintButton
sprintButton=touchButton('Sprint','SPRINT',20,function()
 if controller then controller.sprint=not controller.sprint;sprintButton.Text=controller.sprint and 'SPRINT ON' or 'SPRINT' end
end)
touchButton('Slide','SLIDE',102,function() if controller then controller:SlideOrCrouch() end end)
UIS.JumpRequest:Connect(function() if controller and not UIS:GetFocusedTextBox() then controller:Jump() end end)
UIS.InputBegan:Connect(function(input,processed)
 if processed or UIS:GetFocusedTextBox() then return end
 if input.KeyCode==C.AutoSprintKey and controller then controller.auto=not controller.auto;player:SetAttribute('ZIVRAAutoSprint',controller.auto) end
end)
UIS.WindowFocusReleased:Connect(function() if controller then controller.sprint=false;controller:EndSlide() end end)
RunService.PreAnimation:Connect(function()
 for character,entry in pairs(observers) do
  if not character.Parent then remove(character) else entry.animation:Reset() end
 end
end)
RunService.PreSimulation:Connect(function(dt)
 touchGui.Enabled=UIS.TouchEnabled and not combatActive()
 if controller and not combatActive() then controller:Step(dt) end
 for character,entry in pairs(observers) do
  local root=character:FindFirstChild('HumanoidRootPart')
  if root then
   local state=character==player.Character and controller and controller.state or character:GetAttribute('ZIVRAMovement') or 'Idle'
   entry.animation:Step(math.min(dt,0.1),state,root.AssemblyLinearVelocity)
  end
 end
end)
RunService:BindToRenderStep('ZIVRA_MovementCamera',Enum.RenderPriority.Camera.Value+1,function(dt)
 if controller and not combatActive() and not player:GetAttribute('ZIVRACombatMenu') then controller:CameraStep(math.min(dt,0.1)) end
end)
script.Destroying:Connect(function()
 touchGui:Destroy()
 if controller then controller:Destroy() end
 for character in pairs(observers) do remove(character) end
 RunService:UnbindFromRenderStep('ZIVRA_MovementCamera')
 for _,name in {'ZIVRA_Sprint','ZIVRA_Slide','ZIVRA_Crouch','ZIVRA_Jump'} do CAS:UnbindAction(name) end
end)