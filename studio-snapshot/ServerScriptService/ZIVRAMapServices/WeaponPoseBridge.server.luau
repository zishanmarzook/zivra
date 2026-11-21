if require(game:GetService('ReplicatedStorage'):WaitForChild('ZIVRA').Config).Launch1v1 then return end
-- Server-side ready pose keeps existing muzzle validation consistent with client poses.
local Players=game:GetService('Players');local RunService=game:GetService('RunService')
local poses={
 RightUpperArm=CFrame.Angles(math.rad(90),0,math.rad(4)),
 RightLowerArm=CFrame.identity,
 LeftUpperArm=CFrame.Angles(math.rad(75),math.rad(15),math.rad(-8)),
 LeftLowerArm=CFrame.Angles(math.rad(-25),0,0),
}
local records={}
local function bind(c)
 local h=c:WaitForChild('Humanoid',10);if not h or h.RigType~=Enum.HumanoidRigType.R15 then return end
 local s={h=h,joints={},last={},smooth={}};records[c]=s
 for _,v in c:GetDescendants() do if (v:IsA('Motor6D') or v:IsA('AnimationConstraint')) and v.Part1 and poses[v.Part1.Name] then s.joints[v.Part1.Name]=v end end
end
local function player(p)
 p.CharacterAdded:Connect(bind);p.CharacterRemoving:Connect(function(c) records[c]=nil end)
 if p.Character then task.spawn(bind,p.Character) end
end
Players.PlayerAdded:Connect(player);for _,p in Players:GetPlayers() do player(p) end
RunService.PreAnimation:Connect(function()
 for c,s in pairs(records) do
  if not c.Parent then records[c]=nil;continue end
  for key,offset in pairs(s.last) do local j=s.joints[key];if j.Parent then j.Transform=j.Transform*offset:Inverse() end end
  table.clear(s.last)
 end
end)
RunService.PreSimulation:Connect(function(dt)
 for c,s in pairs(records) do
  local armed=c:FindFirstChildOfClass('Tool')~=nil;local animator=s.h:FindFirstChildOfClass('Animator');local action=false
  if animator then for _,t in animator:GetPlayingAnimationTracks() do if t.Priority.Value>=Enum.AnimationPriority.Action.Value and t.WeightCurrent>0.05 then action=true;break end end end
  for key,joint in pairs(s.joints) do if joint.Parent then
   local target=armed and not action and poses[key] or CFrame.identity
   local offset=(s.smooth[key] or CFrame.identity):Lerp(target,1-math.exp(-18*math.min(dt,0.1)))
   s.smooth[key]=offset;joint.Transform=joint.Transform*offset;s.last[key]=offset
  end end
 end
end)