local Players=game:GetService('Players')
local P=require(script.Parent.PoseLibrary)
local M=require(script.Parent.MotionMath)
local C=require(script.Parent.Config)
local A={};A.__index=A
function A.new(character)
 local self=setmetatable({character=character,motors={},offsets={},smoothed={},tracks={},phase=0},A)
 local h=character:FindFirstChildOfClass('Humanoid');self.h=h
 if not h or h.RigType~=Enum.HumanoidRigType.R15 then return self end
 local animator=h:WaitForChild('Animator',5);self.animator=animator;self.owner=character==Players.LocalPlayer.Character
 for _,v in character:GetDescendants() do if (v:IsA('Motor6D') or v:IsA('AnimationConstraint')) and v.Part1 then self.motors[v.Part1.Name]=v end end
 local animate=character:FindFirstChild('Animate')
 if animate and character==Players.LocalPlayer.Character then
  self.animate=animate;self.wasDisabled=animate.Disabled;animate.Disabled=true
  if animator then for _,t in animator:GetPlayingAnimationTracks() do
   if t.Priority==Enum.AnimationPriority.Core or t.Priority==Enum.AnimationPriority.Movement or t.Priority==Enum.AnimationPriority.Idle then t:Stop(0.12) end
  end end
 end
 if animator and self.owner then for name,id in pairs(C.AnimationIds) do
  if type(id)=='string' and id~='' then
   local animation=Instance.new('Animation');animation.AnimationId=id
   local ok,track=pcall(function() return animator:LoadAnimation(animation) end);animation:Destroy()
   if ok then
    track.Priority=Enum.AnimationPriority.Movement;track.Looped=name~='Jump' and name~='Land' and name~='Slide';self.tracks[name]=track
   else warn('ZIVRA animation fallback:',name,track) end
  end
 end end
 return self
end
function A:Reset()
 for key,offset in pairs(self.offsets) do local joint=self.motors[key]
  if joint and joint.Parent then joint.Transform=joint.Transform*offset:Inverse() end
 end
 table.clear(self.offsets)
end
function A:Step(dt,state,velocity)
 if not self.h or self.h.Health<=0 then return end
 local root=self.character:FindFirstChild('HumanoidRootPart');if not root then return end
 local speed=M.Horizontal(velocity).Magnitude
 self.phase+=(state=='Sprint' and 13 or state=='CrouchWalk' and 6 or 9)*dt*math.clamp(speed/16,0.15,1.6)*C.AnimationSpeed
 local track=self.tracks[state]
 if self.current~=state then
  for _,t in pairs(self.tracks) do t:Stop(C.AnimationFade) end
  if track then track:Play(C.AnimationFade,1,1) end
  self.current=state
 end
 local direction=root.CFrame:VectorToObjectSpace(speed>0.1 and M.Horizontal(velocity).Unit or Vector3.new(0,0,-1))
 local armed=self.character:FindFirstChildOfClass('Tool')~=nil
 local poses=P.Sample(state,self.phase,-direction.Z,direction.X,armed)
 if armed then
  local action=false
  if self.animator then for _,playing in self.animator:GetPlayingAnimationTracks() do
   if playing.Priority.Value>=Enum.AnimationPriority.Action.Value and playing.WeightCurrent>0.05 then action=true;break end
  end end
  if not action then
   -- Original ready pose replaces the default tool hold lost when Animate is disabled.
   -- Any weapon Action track takes full ownership of the arms.
   poses.RightUpperArm=CFrame.Angles(math.rad(90),0,math.rad(4))
   poses.RightLowerArm=CFrame.identity
   poses.LeftUpperArm=CFrame.Angles(math.rad(75),math.rad(15),math.rad(-8))
   poses.LeftLowerArm=CFrame.Angles(math.rad(-25),0,0)
  end
 end
 local remoteTrack=false
 if not self.owner and self.animator and C.AnimationIds[state] then
  for _,playing in self.animator:GetPlayingAnimationTracks() do
   if playing.Animation.AnimationId==C.AnimationIds[state] and playing.WeightCurrent>0.5 then remoteTrack=true;break end
  end
 end
 local useTrack=(track and track.Length>0 or remoteTrack) and not armed
 if track then
  track:AdjustWeight(useTrack and 1 or 0,C.AnimationFade)
  track:AdjustSpeed(state=='Slide' and math.max(0.1,track.Length/C.SlideDuration) or math.clamp(speed/(state=='Sprint' and C.SprintSpeed or C.WalkSpeed),0.35,1.5)*C.AnimationSpeed)
 end
 for key,joint in pairs(self.motors) do if joint.Parent then
  local target=not useTrack and poses[key] or CFrame.identity
  local offset=(self.smoothed[key] or CFrame.identity):Lerp(target or CFrame.identity,M.Alpha(state=='Slide' and 28 or 18,dt))
  self.smoothed[key]=offset;joint.Transform=joint.Transform*offset;self.offsets[key]=offset
 end end
end
function A:Destroy()
 self:Reset()
 for _,t in pairs(self.tracks) do t:Stop(0);t:Destroy() end
 if self.animate and self.animate.Parent then self.animate.Disabled=self.wasDisabled end
end
return A