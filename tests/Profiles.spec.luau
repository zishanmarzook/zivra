local assertions=0
local function check(v,message) assertions+=1; assert(v,message) end
local now=1000
local stored={}; local writes=0; local fail=false; local studio=false; local offline=false
local os={time=function() return now end}
local function deep(x)
	if type(x)~="table" then return x end
	local copy={}; for k,v in pairs(x) do copy[k]=deep(v) end; return copy
end
local Store={UpdateAsync=function(_,key,fn)
	if fail then error("Simulated datastore outage") end
	local value=fn(deep(stored[key]))
	if value~=nil then stored[key]=deep(value); writes+=1 end
	return deep(stored[key])
end}
local token=0
local Http={GenerateGUID=function() token+=1; return tostring(token) end,JSONEncode=function(_,x) return deep(x) end,JSONDecode=function(_,x) return deep(x) end}
local services={DataStoreService={GetDataStore=function() return Store end},HttpService=Http,RunService={IsStudio=function() return studio end}}
local game={GetService=function(_,name) return services[name] end}
local workspace={GetAttribute=function() return offline end}
local task={wait=function() end}
local warn=function() end
local W=require("../src/shared/Weapons")
local R=require("../src/shared/Rules")
-- MODULE_INSERT
local function player(id) return {UserId=id,Kick=function(p,msg) p.kicked=msg end} end
local a=player(1)
local profile=Profiles.load(a)
check(profile and profile.currency==0,"New user gets valid defaults")
check(stored['u:1'].lock~=nil,"Session lock acquired atomically")
profile.currency=42; Profiles.save(a,false)
check(stored['u:1'].data.currency==42,"Save persists server data")
local b=player(1); check(Profiles.load(b)==nil and b.kicked~=nil,"Concurrent join cannot steal live profile")
check(stored['u:1'].data.currency==42,"Blocked concurrent join cannot overwrite data")
Profiles.save(a,true); check(stored['u:1'].lock==nil,"Normal leave releases lock")
local c=player(1); local loaded=Profiles.load(c); check(loaded.currency==42,"Reconnect restores progress")
Profiles.save(c,true)
local original=deep(stored['u:1']); fail=true
local d=player(1); check(Profiles.load(d)==nil,"Live load failure cannot create defaults")
Profiles.save(d,true); check(stored['u:1'].data.currency==original.data.currency,"Load failure cannot overwrite valid data")
studio=true; offline=true
local e=player(1); local temp=Profiles.load(e); check(temp and Profiles.Sessions[e].offline,"Explicit Studio fallback works")
temp.currency=999; local before=writes; Profiles.save(e,true); check(writes==before,"Offline profiles never save")
fail=false; studio=false; offline=false
local f=player(1); Profiles.load(f)
stored['u:1'].lock.token='new-server'; check(not Profiles.save(f,false) and f.kicked~=nil,"Lost session lock stops stale writer")
check(stored['u:1'].data.currency==42,"Lost lock preserves winning writer's data")
stored['u:2']={data={version=999},lock=nil}; local future=player(2)
check(Profiles.load(future)==nil,"Future schema is never downgraded")
stored['u:3']={data={version=0,owned={handgun=true},loadout={'rpg','handgun','knife','medkit'},currency=7},lock=nil}
local migrated=Profiles.load(player(3))
check(migrated.version==1 and migrated.loadout[1]=='assault_rifle' and migrated.currency==7,"Migration repairs invalid loadout while preserving progress")
stored['u:4']={currency=123,version=0}
check(Profiles.load(player(4))==nil and stored['u:4'].currency==123,"Unrecognized record cannot be overwritten with defaults")
print('PASS',assertions,'persistence assertions with mocked DataStore')
