local Players=game:GetService('Players');local Lighting=game:GetService('Lighting')
local Shared=game.ReplicatedStorage:WaitForChild('ZIVRAMapShared')
local C=require(Shared.MapConfig);local Remote=Shared.MapSelection
local player=Players.LocalPlayer
local gui=Instance.new('ScreenGui');gui.Name='ZIVRAMapSelection';gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets;gui.DisplayOrder=20;gui.Parent=player:WaitForChild('PlayerGui')
local panel=Instance.new('Frame');panel.AnchorPoint=Vector2.new(0.5,0.5);panel.Position=UDim2.fromScale(0.5,0.45);panel.Size=UDim2.fromScale(0.85,0.56);panel.BackgroundColor3=Color3.fromRGB(20,28,40);panel.Visible=false;panel.Parent=gui
local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(650,340);cap.MinSize=Vector2.new(260,180);cap.Parent=panel
local title=Instance.new('TextLabel');title.Size=UDim2.new(1,-20,0,36);title.Position=UDim2.fromOffset(10,5);title.BackgroundTransparency=1;title.Text='CHOOSE THE NEXT ARENA';title.TextColor3=Color3.new(1,1,1);title.Font=Enum.Font.GothamBold;title.TextSize=16;title.Parent=panel
local list=Instance.new('ScrollingFrame');list.Size=UDim2.new(1,-24,1,-55);list.Position=UDim2.fromOffset(12,45);list.BackgroundTransparency=1;list.ScrollBarThickness=5;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,8);layout.Parent=list
local status=Instance.new('TextLabel');status.AnchorPoint=Vector2.new(0.5,0);status.Position=UDim2.new(0.5,0,0,14);status.Size=UDim2.new(0.6,0,0,30);status.BackgroundTransparency=0.25;status.BackgroundColor3=Color3.fromRGB(20,28,40);status.TextColor3=Color3.new(1,1,1);status.Font=Enum.Font.GothamBold;status.TextSize=14;status.Visible=false;status.Parent=gui
local buttons={};local snapshot=nil;local version=0;local phase=nil;local deadline=nil;local currentMap=nil
local function restore()
 if snapshot then for key,value in pairs(snapshot) do Lighting[key]=value end;snapshot=nil end
end
Remote.OnClientEvent:Connect(function(action,data)
 version+=1;local serial=version
 if action=='Vote' then
  phase='Vote';deadline=data.deadline
  panel.Visible=true;status.Visible=false;table.clear(buttons)
  for _,v in list:GetChildren() do if v:IsA('GuiObject') then v:Destroy() end end
  for _,id in data.maps do
   local spec=C.Maps[id];local b=Instance.new('TextButton');b.Name=id;b.Size=UDim2.new(1,-8,0,74);b.BackgroundColor3=Color3.fromRGB(43,60,79);b.TextColor3=Color3.new(1,1,1);b.Text='';b.TextWrapped=true;b.TextSize=14;b.Font=Enum.Font.Gotham;b.Modal=true;b.Parent=list
   -- Original color-keyed fallback; use ImageLabel only when a real preview ID is supplied.
   local stripe=Instance.new('Frame');stripe.Size=UDim2.new(0,5,1,0);stripe.BorderSizePixel=0;stripe.BackgroundColor3=id=='Tileyard' and Color3.fromRGB(238,192,65) or Color3.fromRGB(58,156,231);stripe.Parent=b
   local thumb=Instance.new('Frame');thumb.Name='OriginalFallbackPreview';thumb.Position=UDim2.fromOffset(8,5);thumb.Size=UDim2.fromOffset(64,64);thumb.BackgroundColor3=id=='Tileyard' and Color3.fromRGB(210,197,158) or Color3.fromRGB(101,119,133);thumb.BorderSizePixel=3;thumb.BorderColor3=stripe.BackgroundColor3;thumb.Parent=b
   for _,rect in {{0.15,0.18,0.3,0.12},{0.55,0.62,0.3,0.12},{0.37,0.35,0.26,0.25},{0.12,0.58,0.12,0.3},{0.75,0.13,0.12,0.3}} do
    local shape=Instance.new('Frame');shape.Size=UDim2.fromScale(rect[3],rect[4]);shape.Position=UDim2.fromScale(rect[1],rect[2]);shape.BackgroundColor3=stripe.BackgroundColor3;shape.BorderSizePixel=0;shape.Parent=thumb
   end
   if spec.PreviewImage~='' then local image=Instance.new('ImageLabel');image.Size=UDim2.fromScale(1,1);image.Image=spec.PreviewImage;image.Parent=thumb end
   local caption=Instance.new('TextLabel');caption.Position=UDim2.fromOffset(84,6);caption.Size=UDim2.new(1,-94,1,-12);caption.BackgroundTransparency=1;caption.TextColor3=Color3.new(1,1,1);caption.Text=spec.DisplayName..'\n'..spec.Description;caption.TextSize=12;caption.TextWrapped=true;caption.Font=Enum.Font.Gotham;caption.TextXAlignment=Enum.TextXAlignment.Left;caption.Parent=b
   b.Activated:Connect(function() Remote:FireServer('Vote',id) end);buttons[id]=b
  end
 elseif action=='Selected' then for id,b in pairs(buttons) do b.BackgroundColor3=id==data.map and Color3.fromRGB(48,121,144) or Color3.fromRGB(43,60,79) end
 elseif action=='Prepare' then
  phase='Preparing';deadline=nil;panel.Visible=false;status.Visible=true;status.Text='LOADING '..C.Maps[data.map].DisplayName
  task.spawn(function()
   local ok=pcall(function() player:RequestStreamAroundAsync(data.origin,8) end)
   local active=workspace:WaitForChild('ZIVRAActiveMap',10)
   if ok and active and active:GetAttribute('MapId')==data.map and active:FindFirstChild('Geometry') and active:FindFirstChild('Spawns') then
    Remote:FireServer('Ready',data.token)
   end
  end)
 elseif action=='Playing' then
  phase='Playing';deadline=data.deadline;currentMap=data.map
  panel.Visible=false;status.Visible=true;status.Text=C.Maps[data.map].DisplayName
  restore();snapshot={}
  for key,value in pairs(C.Maps[data.map].Lighting) do snapshot[key]=Lighting[key];Lighting[key]=value end
 elseif action=='Lobby' then
  phase=nil;deadline=nil
  panel.Visible=false;restore();status.Visible=true;status.Text=data.message or 'BACK TO LOBBY'
  task.delay(5,function() if version==serial then status.Visible=false end end)
 end
end)
task.spawn(function()
 while gui.Parent do
  if deadline then
   local seconds=math.max(0,math.ceil(deadline-workspace:GetServerTimeNow()))
   if phase=='Vote' then title.Text='CHOOSE THE NEXT ARENA  /  '..seconds..'s'
   elseif phase=='Playing' and currentMap then status.Text=C.Maps[currentMap].DisplayName..'  /  '..string.format('%d:%02d',math.floor(seconds/60),seconds%60) end
  end
  task.wait(1)
 end
end)
