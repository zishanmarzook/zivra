-- Pure policy: testable outside Roblox. No damage/ownership comes from a client.
local Rules={}
function Rules.finite(n) return type(n)=="number" and n==n and math.abs(n)<1e7 end
function Rules.allowed(def,owned,mode)
	return def~=nil and (mode=="Range" and def.trial or owned[def.id]==true)
end
function Rules.falloff(def,distance)
	local start=def.falloffStart or def.range
	if distance<=start then return 1 end
	local t=math.clamp((distance-start)/math.max(1,def.range-start),0,1)
	return 1-t*(1-(def.minDamageScale or 1))
end
function Rules.attack(state,def,now)
	if not state.alive or state.menu or state.mode=="Lobby" then return false,"Combat unavailable" end
	if now<state.busy or now<state.nextShot then return false,"Recovering" end
	if state.overheated then return false,"Cooling" end
	if def.magazine and state.ammo<=0 then return false,"Reload" end
	return true
end
function Rules.splash(damage,distance,radius)
	return damage*math.clamp(1-distance/radius,0,1)
end
function Rules.takeToken(bucket,now,rate,capacity)
	bucket.tokens=math.min(capacity,(bucket.tokens or capacity)+(now-(bucket.time or now))*rate)
	bucket.time=now
	if bucket.tokens<1 then return false end
	bucket.tokens-=1
	return true
end
function Rules.daily(day)
	return {day=day,duels=0,kills=0,wins=0,claimed={}}
end
return Rules
