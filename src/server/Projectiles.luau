local Projectiles={}
local C
function Projectiles.init(combat) C=combat end
function Projectiles.launch(owner,origin,direction,def,charge)
	if #C.Shots>=64 then return false end
	local owned=0; for _,p in ipairs(C.Shots) do if p.owner==owner then owned+=1 end end
	if owned>=8 then return false end
	local damage=def.minDamage and def.minDamage+(def.damage-def.minDamage)*charge or def.damage
	table.insert(C.Shots,{owner=owner,position=origin,velocity=direction*def.speed*(def.charge and (0.45+0.55*charge) or 1),
		def=def,damage=damage,age=0,distance=0,mode=C.States[owner].mode,epoch=C.States[owner].epoch,fxTime=0,fxPosition=origin})
	return true
end
local function detonate(p)
	local d=p.def
	if d.kind=="flash" then
		C.fx("flash",{position=p.position})
		for _,model in ipairs(C.targets(p.owner)) do
			local player=game.Players:GetPlayerFromCharacter(model)
			local head=model:FindFirstChild("Head")
			if player and head then
				local dist=(head.Position-p.position).Magnitude
				if dist<d.radius and C.line(p.position,head.Position,model,p.owner) then
					C.send(player,"Flash",{intensity=1-dist/d.radius,duration=1.5})
				end
			end
		end
	elseif d.kind=="smoke" or d.kind=="molotov" then
		C.Utility.zone(p.owner,p.position,d)
	elseif d.radius then C.explode(p.owner,p.position,d) end
end
function Projectiles.step(dt)
	-- Substeps bound collision error at low server frame rates. Every segment uses a raycast.
	local steps=math.max(1,math.ceil(math.min(dt,0.25)/0.025)); local step=math.min(dt,0.25)/steps
	for i=#C.Shots,1,-1 do
		local p=C.Shots[i]; local s=C.States[p.owner]; local remove=not s or s.mode~=p.mode or not C.alive(p.owner)
		for _=1,steps do
			if remove then break end
			local d=p.def; p.age+=step
			local accel=Vector3.new(0,-workspace.Gravity*(d.gravity or 0),0)
			local delta=p.velocity*step+accel*(0.5*step*step)
			local old=p.position
			local hit=workspace:Raycast(old,delta,C.params(p.owner))
			p.velocity+=accel*step
			p.position=hit and hit.Position+hit.Normal*0.08 or old+delta
			p.distance+=delta.Magnitude
			if p.age>=p.fxTime or hit then
				C.fx("projectile",{position=p.fxPosition,finish=p.position,id=d.id})
				p.fxTime=p.age+0.05; p.fxPosition=p.position
			end
			if hit then
				local model=hit.Instance:FindFirstAncestorOfClass("Model")
				if d.bounce or d.kind=="flash" then
					p.velocity=(p.velocity-2*p.velocity:Dot(hit.Normal)*hit.Normal)*0.55
					if p.velocity.Magnitude<3 then p.velocity=Vector3.zero end
				elseif d.kind=="rocket" or d.kind=="molotov" or d.radius then detonate(p); remove=true
				else
					if model then C.damage(p.owner,model,p.damage,hit.Instance,old,d) end
					C.fx(d.paint and "paint" or d.flare and "flare" or "impact",{position=hit.Position,normal=hit.Normal,id=d.id})
					if d.warp then s.marker=hit.Position+hit.Normal*3; s.markerUntil=os.clock()+5 end
					remove=true
				end
			end
			if not remove and d.fuse and p.age>=d.fuse then detonate(p); remove=true end
			if p.age>8 or p.distance>(d.range or 400)*2 then remove=true end
		end
		if remove then table.remove(C.Shots,i) end
	end
end
return Projectiles
