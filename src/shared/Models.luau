-- Original geometry only. Shared factory keeps thumbnails, held models and viewmodels consistent.
local Models={}
local metal=Color3.fromRGB(43,47,56)
local steel=Color3.fromRGB(166,177,190)
local tan=Color3.fromRGB(191,130,64)
local cyan=Color3.fromRGB(0,189,255)
local function color(def)
	if def.id=="permafrost" or def.id=="freeze_ray" then return Color3.fromRGB(160,235,255) end
	if def.rarity=="Experimental" then return (def.id=="energy_rifle" or def.id=="energy_pistols") and cyan or Color3.fromRGB(162,75,255) end
	return tan
end
function Models.build(def,arms)
	local m=Instance.new("Model"); m.Name=def.id
	local accent=color(def); if typeof(accent)~="Color3" then accent=cyan end
	local function box(name,size,pos,c,rotation,shape)
		local p=Instance.new("Part"); p.Name=name; p.Size=size
		p.CFrame=CFrame.new(pos)*(rotation or CFrame.identity); p.Color=c or metal
		p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false
		p.Material=name=="Glow" and Enum.Material.Neon or Enum.Material.SmoothPlastic
		if shape then p.Shape=shape end
		p:SetAttribute("Rest",p.CFrame); p.Parent=m; return p
	end
	local function b(name,x,y,z,px,py,pz,c,rot) return box(name,Vector3.new(x,y,z),Vector3.new(px,py,pz),c,rot) end
	local function blade(name,length,width,px,py,pz,rot)
		b(name,width,length,0.12,px,py,pz,steel,rot); b("Edge",0.06,length,0.14,px+width/2,py,pz,Color3.new(0.9,0.93,1),rot)
	end
	local function pistol(offset)
		b("Body",0.38,0.4,1.15,offset,0,0,metal); b("Slide",0.4,0.23,1.25,offset,0.26,-0.04,steel)
		b("Grip",0.32,0.7,0.38,offset,-0.45,0.35,metal,CFrame.Angles(-0.15,0,0))
		b("Barrel",0.18,0.18,0.4,offset,0.1,-0.75,metal); b("Glow",0.04,0.08,0.65,offset+0.21,0.05,-0.1,accent)
		b("Sight",0.1,0.13,0.1,offset,0.45,0.3,metal)
	end
	local id=def.id
	if def.kind=="melee" then
		if id=="fists" then
			b("LeftFist",0.5,0.6,0.65,-0.65,0,-0.25,tan); b("RightFist",0.5,0.6,0.65,0.65,0,-0.25,tan)
		elseif id=="riot_shield" then
			b("Shield",2.2,3.2,0.2,0,0,0,metal); b("Window",1.5,0.55,0.23,0,0.8,0,Color3.fromRGB(66,111,137)); b("Stripe",1.9,0.15,0.24,0,-0.6,0,accent)
		elseif id=="chainsaw" then
			b("Engine",0.8,0.65,0.9,0,-0.2,0.4,tan); b("Blade",0.18,0.5,2,0,0,-0.8,steel)
			for i=1,8 do b("Chain",0.22,0.12,0.12,0,0.28,-1.7+i*0.2,metal) end
		elseif id=="daggers" then
			for _,x in ipairs({-0.65,0.65}) do b("Grip",0.22,0.7,0.22,x,-0.65,0,metal); blade("Blade",1.3,0.3,x,0.3,0) end
		else
			local long=id=="spear" or id=="scythe" or id=="maul" or id=="battle_axe"
			b("Grip",0.22,long and 2.8 or 0.8,0.22,0,long and -0.8 or -0.6,0,metal)
			if id=="maul" then b("Hammer",1.6,0.75,0.7,0,0.8,0,steel)
			elseif id=="battle_axe" then b("Axe",1.3,0.9,0.18,0.4,0.7,0,steel,CFrame.Angles(0,0,-0.2))
			elseif id=="scythe" then blade("Blade",2,0.4,0.8,0.8,0,CFrame.Angles(0,0,-1.1))
			elseif id=="trowel" then b("Spade",0.65,0.8,0.1,0,0.2,0,steel,CFrame.Angles(0,0,0.3))
			else blade("Blade",id=="katana" and 3 or id=="spear" and 1.2 or 1.25,id=="spear" and 0.32 or 0.25,0,id=="katana" and 1.2 or 0.35,0)
				b("Guard",0.7,0.12,0.35,0,-0.2,0,tan)
			end
		end
	elseif def.slot==4 then
		if id=="medkit" then
			b("Case",1.25,0.9,0.55,0,0,0,Color3.fromRGB(235,235,230)); b("Cross",0.5,0.17,0.05,0,0,-0.3,Color3.fromRGB(255,65,75)); b("Cross",0.17,0.5,0.05,0,0,-0.31,Color3.fromRGB(255,65,75)); b("Handle",0.5,0.12,0.2,0,0.57,0,metal)
		elseif id=="warpstone" then
			b("Crystal",0.8,1.2,0.8,0,0,0,Color3.fromRGB(112,44,179),CFrame.Angles(0.4,0.6,0.4)); b("Glow",0.6,0.6,0.6,0,0.4,0,accent,CFrame.Angles(0,0,0.8))
		elseif id=="grappler" or id=="freeze_ray" then
			pistol(0); b("Nozzle",0.65,0.55,0.4,0,0.1,-0.85,accent)
			if id=="grappler" then for _,x in ipairs({-0.4,0.4}) do b("Claw",0.15,0.15,0.8,x,0.1,-0.85,steel,CFrame.Angles(0,x,0)) end end
		elseif id=="jump_pad" or id=="subspace_tripmine" then
			b("Plate",1.7,0.25,1.7,0,0,0,metal); b("Glow",1.3,0.1,1.3,0,0.18,0,accent)
		elseif id=="war_horn" then
			for i=1,5 do b("Horn",0.25+i*0.13,0.25+i*0.13,0.3,0,i*0.1,-i*0.24,Color3.fromRGB(184,135,56)) end
		elseif id=="satchel" then
			b("Pack",1.3,0.7,0.7,0,0,0,Color3.fromRGB(54,65,44)); b("Strap",0.15,0.75,0.75,-0.35,0,0,metal); b("Glow",0.2,0.15,0.05,0.3,0,-0.38,Color3.fromRGB(255,65,75))
		elseif id=="molotov" then
			b("Bottle",0.5,1,0.5,0,0,0,Color3.fromRGB(77,107,65)); b("Neck",0.22,0.4,0.22,0,0.7,0,steel); b("Wick",0.12,0.3,0.12,0,1,0,tan)
		else
			b("Canister",0.65,0.9,0.65,0,0,0,id=="smoke_grenade" and steel or metal)
			b("Band",0.68,0.2,0.68,0,0,0,accent); b("Pin",0.45,0.1,0.2,0,0.55,0,steel)
		end
	elseif id=="bow" or id=="crossbow" or id=="slingshot" then
		local cross=id=="crossbow"
		for _,sign in ipairs({-1,1}) do
			b("Limb",0.16,1.3,0.18,cross and sign*0.75 or sign*0.3,cross and 0 or sign*0.75,-0.3,accent,CFrame.Angles(0,0,cross and math.pi/2 or sign*0.3))
		end
		b("Grip",0.23,0.65,cross and 1.8 or 0.23,0,0,0,metal)
		b("String",cross and 2.3 or 0.035,cross and 0.035 or 2.3,0.035,0,0,0.05,steel)
		b("Arrow",0.045,0.045,1.8,0,0,-0.35,steel)
		if id=="slingshot" then m:ScaleTo(0.55) end
	elseif def.slot==2 then
		if def.dual then pistol(-0.75); pistol(0.75) else pistol(0) end
		if id=="revolver" then b("Cylinder",0.55,0.5,0.5,0,0.05,0.1,steel); b("Barrel",0.26,0.26,0.7,0,0.15,-1,steel)
		elseif id=="uzi" or id=="spray" then b("Magazine",0.25,0.9,0.35,0,-0.7,0.25,steel)
		elseif id=="flare_gun" then b("Casing",0.45,0.2,1,0,0,-0.15,Color3.fromRGB(230,79,32))
		elseif id=="exogun" then b("Cell",0.6,0.6,0.5,0,0.4,0.2,Color3.fromRGB(230,191,43))
		end
	else
		b("Receiver",0.52,0.65,1.5,0,0,0,metal); b("Stock",0.42,0.55,0.85,0,-0.05,1.1,metal)
		b("Grip",0.3,0.65,0.4,0,-0.55,0.45,metal,CFrame.Angles(-0.2,0,0))
		b("Magazine",0.35,0.8,0.55,0,-0.55,-0.3,accent)
		b("Barrel",0.2,0.2,1.6,0,0.12,-1.5,steel); b("Handguard",0.5,0.45,0.9,0,0,-0.95,metal)
		b("Sight",0.32,0.22,0.25,0,0.48,0.15,steel); b("Glow",0.05,0.1,0.8,0.28,0.05,-0.25,accent)
		if id=="minigun" then
			for i=1,6 do local a=i*math.pi/3; b("Rotor",0.18,0.18,2,math.cos(a)*0.4,math.sin(a)*0.4,-1.5,steel) end
		elseif id=="rpg" then b("Tube",0.9,0.9,3.6,0,0.15,-0.4,Color3.fromRGB(66,80,45)); b("Rocket",0.6,0.6,1,0,0.15,-2.4,Color3.fromRGB(109,124,56))
		elseif id=="grenade_launcher" then b("Drum",1,1,0.8,0,-0.25,-0.4,steel)
		elseif id=="flamethrower" then b("Tank",0.9,1.1,0.8,0,-0.6,0.2,Color3.fromRGB(178,91,44))
		elseif id=="paintball" then b("Hopper",0.7,0.7,1.1,0,0.8,0,Color3.fromRGB(220,77,161))
		elseif id=="gunblade" then blade("Blade",2.5,0.4,0,-0.35,-1.1,CFrame.Angles(math.pi/2,0,0))
		elseif id=="distortion" then b("Core",0.65,0.65,0.65,0,0.35,-0.7,accent,CFrame.Angles(0,0,0.6))
		end
	end
	if arms then
		b("RightArm",0.38,0.4,1.1,0.2,-0.75,0.8,metal,CFrame.Angles(-0.2,0,0))
		b("LeftArm",0.38,0.4,1.1,-0.4,-0.55,0.1,metal,CFrame.Angles(-0.2,-0.4,0))
	end
	for _,p in ipairs(m:GetChildren()) do if p:IsA("BasePart") then p:SetAttribute("Rest",p.CFrame) end end
	m.WorldPivot=CFrame.identity
	return m
end
return Models
