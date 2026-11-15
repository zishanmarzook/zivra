local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Rules=require(game.ReplicatedStorage.ZIVRA.Rules)
local Store=DataStoreService:GetDataStore("ZIVRA_Profiles_v1")
local Profiles={Sessions={}}
local function defaults()
	local owned={}
	for _,id in ipairs(Weapons.Default) do owned[id]=true end
	return {version=1,owned=owned,loadout=table.clone(Weapons.Default),currency=0,
		settings={quality="Automatic",reduceFlash=true,volume=0.6,sensitivity=1},favorites={},
		daily=Rules.daily(math.floor(os.time()/86400)),stats={kills=0,wins=0,duels=0}}
end
local function migrate(raw)
	if raw==nil then return defaults() end
	assert(type(raw)=="table" and (raw.version or 0)<=1,"Unsupported profile version")
	local p=defaults()
	-- Preserve unknown fields for forwards-compatible migrations, never grant premium ownership.
	for k,v in pairs(raw) do p[k]=v end
	p.version=1
	assert(type(p.settings)=="table" and type(p.stats)=="table" and type(p.favorites)=="table","Malformed profile fields")
	local initial=defaults()
	for k,v in pairs(initial.settings) do if p.settings[k]==nil then p.settings[k]=v end end
	for k in pairs(initial.stats) do assert(type(p.stats[k])=="number" and p.stats[k]>=0,"Malformed statistics") end
	assert(type(p.owned)=="table" and type(p.loadout)=="table","Malformed inventory")
	local loadout={}
	for i,id in ipairs(Weapons.Default) do
		p.owned[id]=true
		local d=Weapons.ById[p.loadout[i]]
		loadout[i]=d and d.slot==i and p.owned[d.id]==true and d.id or id
	end
	p.loadout=loadout
	if not ({Automatic=true,Low=true,Medium=true,High=true})[p.settings.quality] then p.settings.quality="Automatic" end
	if type(p.settings.reduceFlash)~="boolean" then p.settings.reduceFlash=true end
	p.settings.volume=Rules.finite(p.settings.volume) and math.clamp(p.settings.volume,0,1) or 0.6
	p.settings.sensitivity=Rules.finite(p.settings.sensitivity) and math.clamp(p.settings.sensitivity,0.2,2) or 1
	if type(p.settings.hud)~="table" then p.settings.hud={} end
	assert(type(p.currency)=="number" and p.currency>=0,"Malformed currency")
	if type(p.daily)~="table" or p.daily.day~=math.floor(os.time()/86400) then p.daily=Rules.daily(math.floor(os.time()/86400)) end
	assert(type(p.daily.claimed)=="table","Malformed task claims")
	for _,k in ipairs({"duels","kills","wins"}) do assert(type(p.daily[k])=="number" and p.daily[k]>=0,"Malformed task progress") end
	return p
end
local function retry(fn)
	local last
	for i=1,3 do
		local ok,result=pcall(fn)
		if ok then return true,result end
		last=result
		if i<3 then task.wait(i) end
	end
	return false,last
end
function Profiles.load(player)
	if RunService:IsStudio() and workspace:GetAttribute("ZIVRA_OfflineProfiles")==true then
        local session={data=defaults(),offline=true}; Profiles.Sessions[player]=session
        return session.data,"Offline Studio profile (not saved)"
    end
    local token=HttpService:GenerateGUID(false)
	local ok,value=retry(function()
		return Store:UpdateAsync("u:"..player.UserId,function(old)
			assert(old==nil or type(old)=="table" and type(old.data)=="table","Unrecognized record; refusing to overwrite")
			if old and old.lock and old.lock.expires>os.time() and old.lock.token~=token then error("Profile already active") end
			local record={data=migrate(old and old.data),lock={token=token,expires=os.time()+180}}
			return record
		end)
	end)
	if not ok then
		warn("ZIVRA profile load failed: "..tostring(value))
		-- Explicit opt-in only. Never save fallback defaults over a real record.
		if RunService:IsStudio() and workspace:GetAttribute("ZIVRA_OfflineProfiles")==true then
			local session={data=defaults(),offline=true}
			Profiles.Sessions[player]=session
			return session.data,"Offline Studio profile (not saved)"
		end
		player:Kick("ZIVRA could not safely load your profile. Please reconnect shortly.")
		return nil
	end
	Profiles.Sessions[player]={data=value.data,token=token}
	return value.data
end
function Profiles.save(player,release)
	local s=Profiles.Sessions[player]
	if not s or s.offline then if release then Profiles.Sessions[player]=nil end return true end
	-- Serialize saves per session so a late autosave cannot resurrect a released lock.
	while s.saving do task.wait(0.05) end
	if Profiles.Sessions[player]~=s then return true end
	s.saving=true
	local encoded=HttpService:JSONEncode(s.data)
	local snapshot=HttpService:JSONDecode(encoded)
	local lost=false
	local ok,err=retry(function()
		return Store:UpdateAsync("u:"..player.UserId,function(old)
			if not old or not old.lock or old.lock.token~=s.token then lost=true; return nil end
			return {data=snapshot,lock=not release and {token=s.token,expires=os.time()+180} or nil}
		end)
	end)
	s.saving=false
	if lost then
		Profiles.Sessions[player]=nil
		player:Kick("Your ZIVRA profile session changed. Please reconnect.")
		return false
	end
	if not ok then warn("ZIVRA save failed: "..tostring(err)) end
	if release then Profiles.Sessions[player]=nil end
	return ok
end
function Profiles.daily(p)
	local day=math.floor(os.time()/86400)
	if p.daily.day~=day then p.daily=Rules.daily(day) end
	return p.daily
end
return Profiles
