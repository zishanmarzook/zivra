local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Effects={quality="Automatic",volume=0.6,pool={},active=0}
local colors={permafrost=Color3.fromRGB(160,230,255),freeze_ray=Color3.fromRGB(160,230,255),
	energy_rifle=Color3.fromRGB(0,189,255),energy_pistols=Color3.fromRGB(0,189,255),distortion=Color3.fromRGB(162,43,255)}
local folder=Instance.new("Folder"); folder.Name="ZIVRA_LocalEffects"; folder.Parent=workspace
local function take()
	if Effects.active>=80 then return nil end
	local p=table.remove(Effects.pool) or Instance.new("Part")
	p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false
	p.Material=Enum.Material.Neon; p.Transparency=0; p.Shape=Enum.PartType.Block; p.Parent=folder
	Effects.active+=1; return p
end
local function release(p)
	p.Parent=nil; Effects.active-=1
	if #Effects.pool<64 then table.insert(Effects.pool,p) else p:Destroy() end
end
function Effects.line(a,b,color,width,life)
	if (a-b).Magnitude<0.01 then return end
	local p=take(); if not p then return end
	p.Size=Vector3.new(width,width,(a-b).Magnitude); p.CFrame=CFrame.lookAt((a+b)/2,b); p.Color=color
	TweenService:Create(p,TweenInfo.new(life),{Transparency=1}):Play(); task.delay(life,function() release(p) end)
end
function Effects.pulse(position,color,radius,life)
	local p=take(); if not p then return end
	p.Shape=Enum.PartType.Ball; p.Size=Vector3.one*0.4; p.Position=position; p.Color=color; p.Transparency=0.3
	TweenService:Create(p,TweenInfo.new(life),{Size=Vector3.one*radius,Transparency=1}):Play()
	task.delay(life,function() release(p) end)
end
function Effects.play(kind,data)
	local cam=workspace.CurrentCamera
	if not data.position or (cam.CFrame.Position-data.position).Magnitude>350 then return end
	local c=colors[data.id] or Color3.fromRGB(255,183,80)
	local low=Effects.quality=="Low" or Effects.quality=="Automatic" and game.UserInputService.TouchEnabled
	if kind=="shot" or kind=="projectile" then
		Effects.line(data.position,data.finish,c,kind=="shot" and 0.035 or 0.09,0.08)
	elseif kind=="freeze" or kind=="flame" then
		Effects.line(data.position,data.finish,kind=="freeze" and Color3.fromRGB(140,225,255) or c,0.35,0.16)
		if not low then Effects.pulse(data.finish,c,1.3,0.2) end
	elseif kind=="grapple" then
		local player=game.Players:GetPlayerByUserId(data.owner)
		local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local a=Instance.new("Attachment"); a.Parent=root
			local point=Instance.new("Part"); point.Size=Vector3.one*0.1; point.Position=data.finish; point.Transparency=1; point.Anchored=true; point.CanCollide=false; point.CanQuery=false; point.Parent=folder
			local b=Instance.new("Attachment"); b.Parent=point
			local beam=Instance.new("Beam"); beam.Attachment0=a; beam.Attachment1=b; beam.Width0=0.07; beam.Width1=0.07; beam.FaceCamera=true; beam.Color=ColorSequence.new(Color3.fromRGB(160,175,190)); beam.Parent=point
			Debris:AddItem(a,data.duration); Debris:AddItem(point,data.duration)
		end
	elseif kind=="paint" then
		local p=take(); if not p then return end
		p.Size=Vector3.new(0.7,0.7,0.035); p.CFrame=CFrame.lookAt(data.position+data.normal*0.02,data.position+data.normal)
		p.Color=Color3.fromHSV(math.random(),0.65,1); p.Material=Enum.Material.SmoothPlastic
		task.delay(low and 0.4 or 2,function() release(p) end)
	elseif kind=="warp" then
		Effects.pulse(data.position,Color3.fromRGB(162,43,255),5,0.35); Effects.pulse(data.finish,Color3.fromRGB(162,43,255),5,0.35)
	elseif kind=="molotov" then
		local p=take(); if not p then return end
		p.Size=Vector3.new(data.radius*2,0.12,data.radius*2); p.Position=data.position+Vector3.new(0,0.1,0); p.Color=Color3.fromRGB(255,105,30); p.Transparency=0.5
		local fire=Instance.new("Fire"); fire.Size=math.min(data.radius,8); fire.Heat=3; fire.Parent=p
		task.delay(data.duration,function() fire:Destroy(); release(p) end)
	elseif kind=="smoke" then
		-- Essential smoke is replicated by the server, never disabled by cosmetic settings.
	elseif kind=="flare" then
		local p=take(); if not p then return end
		p.Size=Vector3.one*0.3; p.Position=data.position; p.Color=Color3.fromRGB(255,80,30)
		local light=Instance.new("PointLight"); light.Color=p.Color; light.Range=24; light.Brightness=low and 0.8 or 2; light.Parent=p
		task.delay(4,function() light:Destroy(); release(p) end)
	else
		local color=kind=="heal" and Color3.fromRGB(100,255,54) or kind=="shield" and Color3.fromRGB(160,210,255) or c
		Effects.pulse(data.position,color,kind=="explosion" and (data.radius or 10) or 1.5,kind=="explosion" and 0.3 or 0.16)
	end
end
function Effects.audio(def,event,position)
	local id=def.assets.audio[event]
	if not id or id=="" or Effects.volume<=0 then return end
	local carrier=Instance.new("Part"); carrier.Anchored=true; carrier.Transparency=1; carrier.CanCollide=false; carrier.CanQuery=false; carrier.Size=Vector3.one*0.1; carrier.Position=position; carrier.Parent=folder
	local sound=Instance.new("Sound"); sound.SoundId=id; sound.Volume=Effects.volume*0.5; sound.RollOffMinDistance=8; sound.RollOffMaxDistance=120; sound.Parent=carrier
	sound:Play(); Debris:AddItem(carrier,5)
end
return Effects
