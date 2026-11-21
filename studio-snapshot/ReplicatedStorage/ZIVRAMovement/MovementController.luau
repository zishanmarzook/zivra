local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local C=require(script.Parent.Config)
local M=require(script.Parent.MotionMath)
local Camera=require(script.Parent.CameraController)
local Controller={};Controller.__index=Controller
function Controller.new(character,remote)
 local h=character:WaitForChild('Humanoid',10);local root=character:WaitForChild('HumanoidRootPart',10)
 if not h or not root or h.RigType~=Enum.HumanoidRigType.R15 then warn('ZIVRA movement requires R15; keeping native controls.');return nil end
 local self=setmetatable({character=character,h=h,root=root,remote=remote,state='Idle',sprint=false,crouch=false,auto=C.AutoSprint,lastSlide=-math.huge,sequence=0,speed=C.WalkSpeed,connections={},airMomentum=nil},Controller)
 self.old={speed=h.WalkSpeed,use=h.UseJumpPower,jump=h.JumpPower,rotate=h.AutoRotate}
 h.UseJumpPower=true;h.JumpPower=C.JumpPower
 self.camera=Camera.new(h)
 self.params=RaycastParams.new();self.params.FilterType=Enum.RaycastFilterType.Exclude;self.params.FilterDescendantsInstances={character};self.params.RespectCanCollide=true
 table.insert(self.connections,h.Died:Connect(function() self:EndSlide();self.state='Dead' end))
 table.insert(self.connections,h.StateChanged:Connect(function(_,new)
  if new==Enum.HumanoidStateType.Landed then self.landUntil=os.clock()+0.1;self.airMomentum=nil end
 end))
 table.insert(self.connections,remote.OnClientEvent:Connect(function(sequence,accepted)
  if not accepted and sequence==self.slideSequence then self:EndSlide();self.state='Walk' end
 end))
 return self
end
function Controller:Send(action,direction)
 self.sequence+=1;self.remote:FireServer(action,self.sequence,direction);return self.sequence
end
function Controller:Grounded()
 return self.h.FloorMaterial~=Enum.Material.Air and self.root.AssemblyLinearVelocity.Y<8
end
function Controller:Blocked()
 local delta=self.slideDirection*math.max(1.6,self.speed*0.06)
 local origin=self.root.Position
 return workspace:Raycast(origin,delta,self.params) or workspace:Raycast(origin-Vector3.new(0,1,0),delta,self.params)
end
function Controller:SlideOrCrouch()
 if self.slide then self:EndSlide();self.crouch=true;self:Send('Crouch');return end
 local velocity=M.Horizontal(self.root.AssemblyLinearVelocity)
 local wantsSprint=self.sprint or self.auto
 if not self:Grounded() or not wantsSprint or velocity.Magnitude<C.WalkSpeed*0.75 or os.clock()-self.lastSlide<C.SlideCooldown then
  self.crouch=not self.crouch;self:Send(self.crouch and 'Crouch' or 'Walk');return
 end
 self.crouch=false;self.slide=true;self.slideStart=os.clock();self.lastSlide=self.slideStart
 self.slideDirection=velocity.Unit;self.speed=C.SlideSpeed
 self.h.AutoRotate=false
 local attachment=Instance.new('Attachment');attachment.Name='ZIVRASlideAttachment';attachment.Parent=self.root
 local force=Instance.new('LinearVelocity');force.Name='ZIVRASlideVelocity'
 force.Attachment0=attachment;force.RelativeTo=Enum.ActuatorRelativeTo.World
 force.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
 force.PrimaryTangentAxis=Vector3.xAxis;force.SecondaryTangentAxis=Vector3.zAxis
 force.ForceLimitsEnabled=true;force.MaxForce=self.root.AssemblyMass*1800
 force.PlaneVelocity=Vector2.new(self.slideDirection.X*self.speed,self.slideDirection.Z*self.speed)
 force.Parent=self.root;self.slideForce=force;self.slideAttachment=attachment
 self.slideSequence=self:Send('Slide',self.slideDirection)
end
function Controller:EndSlide()
 if not self.slide then return end
 self.slide=false
 if self.slideForce then self.slideForce:Destroy();self.slideForce=nil end
 if self.slideAttachment then self.slideAttachment:Destroy();self.slideAttachment=nil end
 self.h.AutoRotate=self.old.rotate;self:Send('EndSlide')
end
function Controller:Jump()
 if self.h.Health<=0 then return end
 if self.slide then
  local direction=self.slideDirection
  self:Send('SlideJump');self:EndSlide();self.crouch=false
  self.airMomentum=direction*C.SlideJumpSpeed
  self.h:ChangeState(Enum.HumanoidStateType.Jumping)
  self.root.AssemblyLinearVelocity=self.airMomentum+Vector3.new(0,C.JumpPower,0)
 elseif self.crouch then self.crouch=false;self:Send('Walk') end
end
function Controller:Step(dt)
 if self.h.Health<=0 then self.state='Dead';return end
 local hs=self.h:GetState()
 if self.h.Sit or self.root.Anchored or hs==Enum.HumanoidStateType.Swimming or hs==Enum.HumanoidStateType.Climbing or hs==Enum.HumanoidStateType.Physics or hs==Enum.HumanoidStateType.PlatformStanding then
  self:EndSlide();self.state='Idle';return
 end
 dt=math.min(dt,0.1)
 local grounded=self:Grounded();local direction=self.h.MoveDirection
 local velocity=self.root.AssemblyLinearVelocity
 if self.slide then
  local elapsed=os.clock()-self.slideStart
  if elapsed>=C.SlideDuration or not grounded or self:Blocked() then
   self:EndSlide()
  else
   if direction.Magnitude>0.1 then
    local turned=self.slideDirection:Lerp(M.Horizontal(direction).Unit,math.min(dt*C.SlideSteering,0.2))
    if turned.Magnitude>0.1 then self.slideDirection=turned.Unit end
   end
   self.speed=M.SlideSpeed(C,elapsed)
   if self.slideForce then self.slideForce.PlaneVelocity=Vector2.new(self.slideDirection.X*self.speed,self.slideDirection.Z*self.speed) end
   -- Native humanoid collision remains active; no teleporting or disabling walls.
   self.root.AssemblyLinearVelocity=self.slideDirection*self.speed+Vector3.new(0,velocity.Y,0)
   self.h.WalkSpeed=C.SlideEndSpeed;self.state='Slide';self.character:SetAttribute('ZIVRALocalMovement',self.state);return
  end
 end
 local setting=Players.LocalPlayer:GetAttribute('ZIVRASettingAutoSprint')
 if setting~=nil and self.lastAutoSetting~=setting then self.auto=setting;self.lastAutoSetting=setting end
 local sprinting=(self.sprint or self.auto) and not self.crouch and direction.Magnitude>0.05
 local target=self.crouch and C.CrouchSpeed or sprinting and C.SprintSpeed or C.WalkSpeed
 self.speed=M.Approach(self.speed,target,dt*(self.speed<target and C.Acceleration or C.Deceleration))
 self.h.WalkSpeed=self.speed
 if self.airMomentum then
  if grounded then self.airMomentum=nil
  else
   local flat=M.Horizontal(velocity)
   local targetAir=self.airMomentum
   if direction.Magnitude>0.05 then targetAir=targetAir:Lerp(direction*C.SlideJumpSpeed,math.min(dt*1.2,0.1)) end
   local nextV=flat:Lerp(targetAir,M.Alpha(5,dt))
   if nextV.Magnitude>C.AirSpeedCap then nextV=nextV.Unit*C.AirSpeedCap end
   self.airMomentum=targetAir
   self.root.AssemblyLinearVelocity=nextV+Vector3.new(0,velocity.Y,0)
  end
 end
 if not grounded then self.state=velocity.Y>1 and 'Jump' or 'Fall'
 elseif self.landUntil and os.clock()<self.landUntil then self.state='Land'
 elseif self.crouch then self.state=direction.Magnitude>0.05 and 'CrouchWalk' or 'Crouch'
 else self.state=direction.Magnitude<0.05 and 'Idle' or sprinting and 'Sprint' or 'Walk' end
 local intent=self.crouch and 'Crouch' or sprinting and 'Sprint' or 'Walk'
 if self.intent~=intent then self.intent=intent;self:Send(intent) end
 self.character:SetAttribute('ZIVRALocalMovement',self.state)
end
function Controller:ResetIntent()
 self:EndSlide()
 self.sprint=false;self.crouch=false;self.airMomentum=nil;self.intent=nil;self.speed=C.WalkSpeed
 self.state='Idle';self.h.CameraOffset=Vector3.zero
 self.character:SetAttribute('ZIVRALocalMovement','Idle')
end
function Controller:CameraStep(dt,combat)
 local aiming=self.character:GetAttribute('Aiming')==true or Players.LocalPlayer:GetAttribute('Aiming')==true or self.character:GetAttribute('ZIVRAAiming')==true
 self.camera:Step(dt,self.state,self.root.AssemblyLinearVelocity,self:Grounded(),aiming,combat)
end
function Controller:Destroy()
 self:EndSlide()
 for _,c in self.connections do c:Disconnect() end
 self.camera:Destroy()
 if self.h.Parent then self.h.WalkSpeed=self.old.speed;self.h.UseJumpPower=self.old.use;self.h.JumpPower=self.old.jump;self.h.AutoRotate=self.old.rotate end
end
return Controller