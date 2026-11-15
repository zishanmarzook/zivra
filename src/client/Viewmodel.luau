local Models=require(game.ReplicatedStorage.ZIVRA.Models)
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Viewmodel={kick=0,aim=false,visible=true,charge=0,landing=0,shotSide=1}
function Viewmodel.equip(id)
	if Viewmodel.id==id and Viewmodel.model then return end
	if Viewmodel.model then Viewmodel.model:Destroy() end
	Viewmodel.id=id; Viewmodel.def=Weapons.ById[id]; Viewmodel.model=Models.build(Viewmodel.def,true)
	Viewmodel.parts=Viewmodel.model:GetChildren(); Viewmodel.equipped=os.clock(); Viewmodel.kick=0
	Viewmodel.model.Parent=workspace.CurrentCamera
end
function Viewmodel.fire()
	Viewmodel.kick=math.min(0.4,Viewmodel.kick+0.08*(Viewmodel.def.recoil or 1)); Viewmodel.fired=os.clock(); Viewmodel.shotSide*=-1
end
function Viewmodel.reload(duration) Viewmodel.reloadStart=os.clock(); Viewmodel.reloadDuration=duration end
function Viewmodel.step(dt,humanoid,menu)
	local m=Viewmodel.model; if not m then return end
	local cam=workspace.CurrentCamera; m.Parent=cam
	local now=os.clock(); local d=Viewmodel.def
	local movement=humanoid and humanoid.MoveDirection.Magnitude or 0
	local airborne=humanoid and humanoid.FloorMaterial==Enum.Material.Air
	if Viewmodel.wasAir and not airborne then Viewmodel.landing=0.12 end
	Viewmodel.wasAir=airborne; Viewmodel.landing*=math.exp(-dt*10)
	Viewmodel.kick*=math.exp(-dt*14)
	local reload=Viewmodel.reloadStart and math.clamp((now-Viewmodel.reloadStart)/Viewmodel.reloadDuration,0,1) or 1
	local reloadPose=reload<1 and math.sin(reload*math.pi) or 0
	local equip=math.max(0,1-(now-Viewmodel.equipped)/0.25)
	local inspect=math.clamp(((Viewmodel.inspectUntil or 0)-now),0,1)
	local mouse=game.UserInputService:GetMouseDelta()
	local melee=d.kind=="melee" and math.max(0,1-(now-(Viewmodel.fired or 0))/0.3) or 0
	local bob=math.sin(now*(humanoid and humanoid.WalkSpeed or 16)*0.6)*0.025*movement
	local pose=CFrame.new(Viewmodel.aim and 0.1 or 0.65,-0.7+bob-reloadPose*0.3-equip*0.7-Viewmodel.landing,-1.55+Viewmodel.kick)
		*CFrame.Angles(reloadPose*0.45+Viewmodel.kick*0.4,math.clamp(-mouse.X*0.001,-0.06,0.06),-melee*0.9+inspect*0.6+math.clamp(-mouse.Y*0.001,-0.04,0.04))
	m:PivotTo(cam.CFrame*pose)
	for _,p in ipairs(Viewmodel.parts) do
		if p:IsA("BasePart") then
			p.LocalTransparencyModifier=(menu or not Viewmodel.visible) and 1 or 0
			local rest=p:GetAttribute("Rest")
			if rest then
				local offset=CFrame.identity
				if p.Name=="Magazine" then offset=CFrame.new(0,-reloadPose*0.8,reloadPose*0.1)
				elseif p.Name=="Slide" then offset=CFrame.new(0,0,Viewmodel.kick*2)
				elseif p.Name=="Rotor" then offset=rest:Inverse()*CFrame.Angles(0,0,now*(Viewmodel.firing and 35 or 3))*rest
				elseif p.Name=="Core" then offset=CFrame.Angles(0,now*2,0)
				elseif p.Name=="String" or p.Name=="Arrow" then offset=CFrame.new(0,0,Viewmodel.charge*0.4)
				elseif p.Name=="Cylinder" then offset=CFrame.Angles(0,0,Viewmodel.kick*4)
				elseif p.Name=="Chain" then offset=CFrame.new(0,0,math.sin(now*55)*0.05)
				end
				p.CFrame=m:GetPivot()*rest*offset
			end
		end
	end
end
return Viewmodel
