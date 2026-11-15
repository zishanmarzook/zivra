local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local gui=script.Parent
local hud=gui:WaitForChild("LobbyHUD")
local first=true
local button=Instance.new("TextButton")
button.Name="CameraToggle";button.AnchorPoint=Vector2.new(1,0)
button.Position=UDim2.new(1,-18,0,18);button.Size=UDim2.fromOffset(44,44)
button.BackgroundTransparency=1;button.Text="";button.AutoButtonColor=false
button.Modal=false;button.Parent=hud
-- Hold Alt to reach queue controls and camera toggle during desktop FPS play.
UIS.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.LeftAlt then button.Modal=true end
end)
UIS.InputEnded:Connect(function(input)
 if input.KeyCode==Enum.KeyCode.LeftAlt then button.Modal=false end
end)
UIS.WindowFocusReleased:Connect(function() button.Modal=false end)
button:SetAttribute("AccessibleLabel","Switch camera view")
local tint=Color3.fromRGB(245,237,218)
local body=Instance.new("Frame");body.Name="CameraIcon";body.AnchorPoint=Vector2.new(0.5,0.5);body.Position=UDim2.fromScale(0.5,0.55);body.Size=UDim2.fromOffset(26,18);body.BackgroundTransparency=1;body.Parent=button
local shape=Instance.new("UICorner");shape.CornerRadius=UDim.new(0,4);shape.Parent=body
local stroke=Instance.new("UIStroke");stroke.Color=tint;stroke.Thickness=1.5;stroke.Transparency=0.24;stroke.Parent=body
local lens=Instance.new("Frame");lens.Name="Lens";lens.AnchorPoint=Vector2.new(0.5,0.5);lens.Position=UDim2.fromScale(0.5,0.5);lens.Size=UDim2.fromOffset(10,10);lens.BackgroundTransparency=1;lens.Parent=body
local circle=Instance.new("UICorner");circle.CornerRadius=UDim.new(1,0);circle.Parent=lens
local outline=Instance.new("UIStroke");outline.Color=tint;outline.Thickness=1.5;outline.Transparency=0.24;outline.Parent=lens
local top=Instance.new("Frame");top.Name="CameraTop";top.Size=UDim2.fromOffset(10,4);top.Position=UDim2.new(0.5,-5,0,-4);top.BackgroundColor3=tint;top.BackgroundTransparency=0.24;top.BorderSizePixel=0;top.Parent=body
local cap=Instance.new("UICorner");cap.CornerRadius=UDim.new(0,2);cap.Parent=top
button.MouseEnter:Connect(function() stroke.Transparency=0;outline.Transparency=0;top.BackgroundTransparency=0 end)
button.MouseLeave:Connect(function() stroke.Transparency=0.24;outline.Transparency=0.24;top.BackgroundTransparency=0.24 end)
local function apply()
 if first then
  player.CameraMode=Enum.CameraMode.LockFirstPerson
  button:SetAttribute("View", "FirstPerson")
 else
  player.CameraMode=Enum.CameraMode.Classic
  player.CameraMinZoomDistance=8
  player.CameraMaxZoomDistance=20
  button:SetAttribute("View", "ThirdPerson")
 end
 button:SetAttribute("FirstPerson",first)
 hud.Crosshair.Visible=first
end
button.Activated:Connect(function() first=not first;apply() end)
-- Modal keeps the cursor available for the camera and queue buttons.
-- Hold right mouse to look around on desktop; mobile retains native camera dragging.
player.CharacterAdded:Connect(function() task.defer(apply) end)
apply()
