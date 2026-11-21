-- Original R15 motion, shared by keyframe authoring and runtime fallback.
-- Angles are degrees. No extracted animation data or inaccessible assets.
local P={}
local function rot(x,y,z) return CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0)) end
function P.Sample(state,phase,forward,side,armed)
 local p={};local s=math.sin(phase);local co=math.cos(phase)
 forward=forward or 1;side=side or 0
 local moving=state=='Walk' or state=='Sprint' or state=='CrouchWalk'
 local crouch=state=='Crouch' or state=='CrouchWalk'
 local slide=state=='Slide' or state=='SlideStart' or state=='SlideLoop' or state=='SlideEnd' or state=='SlideCancel'
 p.LowerTorso=rot(0,0,0);p.UpperTorso=rot(0,0,0)
 p.LeftUpperLeg=rot(0);p.RightUpperLeg=rot(0)
 p.LeftLowerLeg=rot(4);p.RightLowerLeg=rot(4)
 p.LeftFoot=rot(-2);p.RightFoot=rot(-2)
 if not armed then
  p.LeftUpperArm=rot(0,0,-5);p.RightUpperArm=rot(0,0,5)
  p.LeftLowerArm=rot(-8);p.RightLowerArm=rot(-8)
 end
 if moving then
  local sprint=state=='Sprint';local amp=sprint and 43 or crouch and 19 or 28
  p.LowerTorso=CFrame.new(0,-0.025*math.abs(s),0)*rot(sprint and -9 or crouch and -14 or -3,-side*6,-side*5)
  p.UpperTorso=rot(0,co*(sprint and 5 or 3),side*2)
  p.LeftUpperLeg=rot(s*amp*forward+(crouch and -28 or 0),side*8,s*side*18)
  p.RightUpperLeg=rot(-s*amp*forward+(crouch and -28 or 0),side*8,-s*side*18)
  p.LeftLowerLeg=rot(7+math.max(0,-s)*amp*1.35+(crouch and 32 or 0))
  p.RightLowerLeg=rot(7+math.max(0,s)*amp*1.35+(crouch and 32 or 0))
  p.LeftFoot=rot(-math.max(0,s)*12);p.RightFoot=rot(-math.max(0,-s)*12)
  if not armed then
   p.LeftUpperArm=rot(-s*(sprint and 39 or 18)*forward,0,-7)
   p.RightUpperArm=rot(s*(sprint and 39 or 18)*forward,0,7)
   p.LeftLowerArm=rot(sprint and -65 or -14);p.RightLowerArm=rot(sprint and -65 or -14)
  end
 elseif slide then
  p.LowerTorso=CFrame.new(0,-0.62,0)*rot(27,0,-8);p.UpperTorso=rot(-12,8,0)
  p.LeftUpperLeg=rot(-78,-8,-9);p.RightUpperLeg=rot(-48,12,15)
  p.LeftLowerLeg=rot(14);p.RightLowerLeg=rot(86)
  p.LeftFoot=rot(14);p.RightFoot=rot(-20)
  if not armed then p.LeftUpperArm=rot(22,0,-23);p.RightUpperArm=rot(-20,0,16) end
 elseif crouch then
  p.LowerTorso=CFrame.new(0,-0.35,0)*rot(-13);p.UpperTorso=rot(7)
  p.LeftUpperLeg=rot(-39,0,-5);p.RightUpperLeg=rot(-39,0,5)
  p.LeftLowerLeg=rot(69);p.RightLowerLeg=rot(69);p.LeftFoot=rot(-29);p.RightFoot=rot(-29)
 elseif state=='Mantle' or state=='Vault' then
  local mantle=state=='Mantle'
  p.LowerTorso=rot(mantle and -20 or -36)
  p.UpperTorso=rot(-12)
  p.LeftUpperArm=rot(mantle and 145 or 95,0,-16);p.RightUpperArm=rot(mantle and 145 or 95,0,16)
  p.LeftLowerArm=rot(-32);p.RightLowerArm=rot(-36)
  p.LeftUpperLeg=rot(-53,0,-6);p.RightUpperLeg=rot(-36,0,7)
  p.LeftLowerLeg=rot(64);p.RightLowerLeg=rot(71)
 elseif state=='Jump' then
  p.LowerTorso=rot(-6);p.LeftUpperLeg=rot(-27,0,-5);p.RightUpperLeg=rot(15,0,5)
  p.LeftLowerLeg=rot(40);p.RightLowerLeg=rot(30)
 elseif state=='Fall' then
  p.LowerTorso=rot(5);p.LeftUpperLeg=rot(-10,0,-7);p.RightUpperLeg=rot(7,0,7)
  p.LeftLowerLeg=rot(20);p.RightLowerLeg=rot(28)
 elseif state=='Land' then
  p.LowerTorso=CFrame.new(0,-0.14,0)*rot(-9)
  p.LeftUpperLeg=rot(-20);p.RightUpperLeg=rot(-20);p.LeftLowerLeg=rot(34);p.RightLowerLeg=rot(34)
 else
  p.UpperTorso=rot(math.sin(phase*0.35)*0.7)
 end
 return p
end
return P