local M=require(script.Parent.MotionMath)
local C=require(script.Parent.Config)
local Camera={};Camera.__index=Camera
function Camera.new(h)
 return setmetatable({h=h,offset=Vector3.zero,phase=0,roll=0,landing=0,wasGrounded=true},Camera)
end
function Camera:Step(dt,state,velocity,grounded,aiming)
 local camera=workspace.CurrentCamera;if not camera or camera.CameraType==Enum.CameraType.Scriptable then return end
 if self.camera~=camera then self.camera=camera;self.base=C.BaseFOV;camera.FieldOfView=self.base;self.lastFOV=nil end
 if self.lastFOV and math.abs(camera.FieldOfView-self.lastFOV)>0.05 then self.base=camera.FieldOfView end
 local scale=C.MotionScale*(aiming and 0.15 or 1)
 local speed=M.Horizontal(velocity).Magnitude
 self.phase+=dt*(state=='Sprint' and 15 or 10)*math.clamp(speed/16,0,1.7)
 if grounded and not self.wasGrounded then self.landing=math.clamp(math.abs(self.lastY or 0)/80,0,0.16)*scale end
 self.wasGrounded=grounded;self.lastY=velocity.Y;self.landing*=math.exp(-18*dt)
 local drop=state=='Slide' and C.SlideCameraDrop or (state=='Crouch' or state=='CrouchWalk') and C.CrouchCameraDrop or 0
 local bob=grounded and speed>1 and state~='Slide' and math.sin(self.phase*2)*C.CameraBob*scale or 0
 self.offset=self.offset:Lerp(Vector3.new(0,-drop+bob-self.landing,0),M.Alpha(C.CameraSmooth,dt));self.h.CameraOffset=self.offset
 local right=camera.CFrame.RightVector:Dot(M.Horizontal(velocity))/C.SprintSpeed
 self.roll+=(-math.clamp(right,-1,1)*math.rad(C.CameraRoll)*scale-self.roll)*M.Alpha(14,dt)
 camera.CFrame=camera.CFrame*CFrame.Angles(0,0,self.roll)
 local targetFOV=aiming and self.base or self.base+(state=='Sprint' and C.SprintFOV-C.BaseFOV or 0)
 camera.FieldOfView+=(targetFOV-camera.FieldOfView)*M.Alpha(10,dt);self.lastFOV=camera.FieldOfView
end
function Camera:Destroy()
 if self.h.Parent then self.h.CameraOffset=Vector3.zero end
 if self.camera and self.lastFOV and math.abs(self.camera.FieldOfView-self.lastFOV)<0.1 then self.camera.FieldOfView=self.base end
end
return Camera