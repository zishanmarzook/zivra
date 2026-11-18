local W=require("../src/shared/Weapons")
local R=require("../src/shared/Rules")
local count=0
local function check(x,message) count+=1; assert(x,message) end
check(#W.List==48,"All named items must be registered")
local totals={0,0,0,0}; local seen={}
local kinds={auto=true,burst=true,pellets=true,rocket=true,grenade=true,flame=true,charge=true,bolt=true,semi=true,melee=true,
	grapple=true,heal=true,mine=true,warp=true,flash=true,freeze=true,pad=true,molotov=true,satchel=true,smoke=true,horn=true}
for _,d in ipairs(W.List) do
	check(not seen[d.id],"Duplicate ID "..d.id); seen[d.id]=true
	check(kinds[d.kind],"Missing behavior "..d.kind); totals[d.slot]+=1
	check(d.damage>=0 and d.interval>0 and d.range>0,"Invalid balance "..d.id)
	check(d.model==d.id and d.assets.model=="Procedural","Model contract")
	if d.magazine then check(d.reserve>=d.magazine and d.reload>0,"Ammo contract") end
	if d.slot==4 then check(d.cooldown>0 and d.charges>0,"Utility must be bounded") end
end
for i,n in ipairs({15,11,10,12}) do check(totals[i]==n,"Category count mismatch") end
local owned={}; for slot,id in ipairs(W.Default) do owned[id]=true; check(W.ById[id].slot==slot,"Exactly one starter per slot") end
check(not R.allowed(W.ById.rpg,owned,"Lobby"),"Lobby cannot unlock trial")
check(R.allowed(W.ById.rpg,owned,"Range"),"Range must allow trial")
check(not R.allowed(W.ById.rpg,owned,"Duel"),"Trial must not leak into duel")
check(not R.allowed(nil,owned,"Range"),"Unknown ID must be rejected")
check(R.allowed(W.ById.knife,owned,"Duel"),"Owned weapon should work")
for _,v in ipairs({0/0,math.huge,-math.huge,1e12,"20",{}}) do check(not R.finite(v),"Reject invalid scalar") end
local s={alive=true,menu=false,mode="Duel",busy=0,nextShot=0,ammo=1}
check(R.attack(s,W.ById.assault_rifle,1),"Ready shot")
for key,value in pairs({alive=false,menu=true,mode="Lobby",busy=2,nextShot=2,overheated=true,ammo=0}) do
	local bad=table.clone(s); bad[key]=value; check(not R.attack(bad,W.ById.assault_rifle,1),"Reject attack: "..key)
end
check(R.splash(75,0,15)==75,"Splash maximum")
check(R.splash(75,15,15)==0 and R.splash(75,30,15)==0,"Splash boundary")
check(R.splash(75,7.5,15)==37.5,"Splash falloff")
check(R.falloff(W.ById.shotgun,0)==1,"Point blank falloff")
check(math.abs(R.falloff(W.ById.shotgun,90)-0.08)<1e-6,"Shotgun range floor")
local bucket={}
for _=1,50 do check(R.takeToken(bucket,0,36,50),"Initial bucket") end
check(not R.takeToken(bucket,0,36,50),"Flood must be rejected")
check(R.takeToken(bucket,1,36,50),"Bucket refill")
local day=R.daily(3); day.claimed.duels=true
check(R.daily(4).claimed.duels==nil,"Daily claims cannot leak across days")
print("PASS",count,"registry and policy assertions")
