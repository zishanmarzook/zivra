local Players=game:GetService('Players');local RS=game:GetService('ReplicatedStorage');local RunService=game:GetService('RunService');local TweenService=game:GetService('TweenService')
local shared=RS:WaitForChild('ZIVRA');local config=require(shared.Config);local remote=shared.QueueAction;local root=workspace:WaitForChild('ZIVRA_Corridor');local gui=script.Parent
local frame=Instance.new('Frame');frame.AnchorPoint=Vector2.new(0.5,1);frame.Position=UDim2.fromScale(0.5,0.95);frame.Size=UDim2.new(0.88,0,0,108);frame.BackgroundColor3=Color3.fromRGB(15,19,31);frame.BackgroundTransparency=0.08;frame.Visible=false;frame.Parent=gui
local constraint=Instance.new('UISizeConstraint');constraint.MaxSize=Vector2.new(520,108);constraint.Parent=frame
local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,12);corner.Parent=frame
local text=Instance.new('TextLabel');text.Size=UDim2.new(1,-16,0,56);text.Position=UDim2.fromOffset(8,0);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=16;text.TextWrapped=true;text.TextColor3=Color3.fromRGB(225,235,255);text.Parent=frame
local leave=Instance.new('TextButton');leave.Size=UDim2.new(1,-24,0,38);leave.Position=UDim2.fromOffset(12,62);leave.BackgroundColor3=Color3.fromRGB(105,51,180);leave.Text='LEAVE QUEUE';leave.TextColor3=Color3.new(1,1,1);leave.Font=Enum.Font.GothamBold;leave.TextSize=16;leave.Parent=frame
leave.Activated:Connect(function() remote:FireServer('Leave') end)
local selected,noticeVersion=nil,0
remote.OnClientEvent:Connect(function(action,value)
 noticeVersion+=1
 if action=='Joined' then selected=root.Stations:FindFirstChild(value);frame.Visible=true;leave.Visible=true
  if selected then for _,p in selected:GetChildren() do if p.Name=='Outline' then local c=p.Color;p.Color=Color3.new(1,1,1);TweenService:Create(p,TweenInfo.new(0.6),{Color=c}):Play() end end end
 elseif action=='Left' then selected=nil;frame.Visible=false
 elseif action=='Notice' then selected=nil;frame.Visible=true;leave.Visible=false;text.Text=value;local version=noticeVersion;task.delay(4,function() if noticeVersion==version then frame.Visible=false end end)
 end
end)
local holograms={};for _,v in root:GetDescendants() do if v:IsA('BasePart') and v:GetAttribute('AnimateHologram') then table.insert(holograms,{part=v,cf=v.CFrame}) end end
local elapsed,acc=0,0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt;acc+=dt;if acc<1/30 then return end;acc=0
 local character=Players.LocalPlayer.Character;local hrp=character and character:FindFirstChild('HumanoidRootPart')
 for _,entry in ipairs(holograms) do if hrp and (hrp.Position-entry.cf.Position).Magnitude<110 then entry.part.CFrame=entry.cf*CFrame.new(0,0.45*math.sin(elapsed*1.4),0)*CFrame.Angles(0,elapsed*0.5,math.pi/4);entry.part.Transparency=0.42+0.12*math.sin(elapsed*2) end end
 if selected then text.Text=selected.Name..'  â€¢  '..tostring(selected:GetAttribute('QueueCount') or 0)..'/'..tostring(selected:GetAttribute('Capacity') or '?')..'\n'..tostring(selected:GetAttribute('Status') or '') end
end)
if config.AmbientSoundId>0 then local sound=Instance.new('Sound');sound.Name='ZIVRAAmbience';sound.SoundId='rbxassetid://'..config.AmbientSoundId;sound.Volume=config.AmbientVolume;sound.Looped=true;sound.Parent=game:GetService('SoundService');sound:Play() end
