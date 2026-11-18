-- Initial playtest balance. IDs are stable persistence keys, never display names.
local Weapons = { Categories = {"Primary", "Secondary", "Melee", "Utility"}, List = {}, ById = {} }
Weapons.Launch={assault_rifle=true,sniper_rifle=true,shotgun=true,revolver=true,handgun=true,knife=true,medkit=true}
local function add(id, name, slot, kind, values)
	local d = {id=id, name=name, slot=slot, kind=kind, rarity="Standard", trial=true,
		description=name, equip=0.22, recovery=0.1, range=300, damage=20, headshot=1.5,
		interval=0.2, spread=0.6, recoil=1, model=id, statusDuration=0,
		-- Original procedural blockouts; commissioned animation/audio assets still required.
		assets={model="Procedural", animation="Procedural", audio={}}, productionReady=false}
	for k,v in pairs(values or {}) do d[k]=v end
	d.unlock = Weapons.Launch[id] and "Starter" or "Range trial only; unlock economy pending"
	Weapons.ById[id]=d
	table.insert(Weapons.List,d)
end
local function gun(id,name,slot,kind,damage,mag,interval,extra)
	local v={damage=damage,magazine=mag,reserve=mag*4,reload=1.8,interval=interval,falloffStart=90,minDamageScale=0.45}
	for k,x in pairs(extra or {}) do v[k]=x end
	add(id,name,slot,kind,v)
end
-- Primary: all 14 explicitly named items.
gun("assault_rifle","Assault Rifle",1,"auto",17,30,0.1,{spread=0.7,bloom=2,recoil=1.1})
gun("burst_rifle","Burst Rifle",1,"burst",18,27,0.09,{burst=3,burstPause=0.28,spread=0.35,recoil=1.5})
gun("sniper_rifle","Sniper Rifle",1,"semi",55,5,1.35,{headshot=2,spread=0.05,reload=2.8,recoil=3.6,falloffStart=300})
gun("shotgun","Shotgun",1,"pellets",2.75,6,0.85,{pellets=8,spread=3.2,range=90,falloffStart=18,minDamageScale=0.08,reload=2.6,recoil=3})
gun("minigun","Minigun",1,"auto",9,120,1/15,{spinup=0.7,heatPerShot=0.035,cooling=0.22,spread=3,moveScale=0.65,reload=3.4})
gun("rpg","RPG",1,"rocket",75,1,1.6,{speed=115,gravity=0,radius=16,range=450,reload=3,recoil=4})
gun("grenade_launcher","Grenade Launcher",1,"grenade",60,4,0.8,{speed=85,gravity=0.65,radius=13,fuse=2.1,bounce=true,reload=2.8})
gun("flamethrower","Flamethrower",1,"flame",4,100,0.1,{range=22,cone=0.88,burn=1.5,spread=0,reload=3,damageType="Fire"})
gun("bow","Bow",1,"charge",80,1,0.65,{minDamage=30,speed=160,gravity=0.25,charge=1.1,reload=0.65,spread=0.1,recoil=0.5})
gun("crossbow","Crossbow",1,"bolt",65,1,0.85,{speed=240,gravity=0.12,reload=1.6,spread=0.1})
gun("energy_rifle","Energy Rifle",1,"semi",28,20,0.28,{spread=0.15,rarity="Experimental",heatPerShot=0.09,cooling=0.3,damageType="Energy"})
gun("permafrost","Permafrost",1,"semi",18,18,0.32,{slow=0.7,rarity="Experimental",damageType="Cold"})
gun("distortion","Distortion",1,"semi",30,12,0.42,{distort=0.35,rarity="Experimental",heatPerShot=0.15,cooling=0.3})
gun("paintball","Paintball",1,"bolt",13,35,0.12,{speed=190,gravity=0.08,paint=true,spread=1,recoil=0.6,automatic=true})
gun("gunblade","Gunblade",1,"semi",23,8,0.4,{slash=42,meleeRange=7,rarity="Experimental"})
-- Secondary: all 11 explicitly named items.
gun("handgun","Handgun",2,"semi",25,12,0.24,{reload=1.3,spread=0.4})
gun("revolver","Revolver",2,"semi",34,6,0.7,{reload=2.5,recoil=2.5,spread=0.2})
gun("shorty","Shorty",2,"pellets",8,2,0.65,{pellets=7,spread=8,range=55,falloffStart=10,minDamageScale=0.05,reload=1.7})
gun("uzi","Uzi",2,"auto",12,25,0.075,{spread=1.8,bloom=3,reload=1.4})
gun("spray","Spray",2,"auto",10,35,0.065,{spread=2.2,bloom=5,reload=1.7})
gun("energy_pistols","Energy Pistols",2,"auto",16,30,0.14,{dual=true,rarity="Experimental",damageType="Energy"})
gun("exogun","Exogun",2,"bolt",38,5,0.7,{speed=140,gravity=0,radius=4,rarity="Experimental"})
gun("warper","Warper",2,"bolt",12,8,0.6,{speed=130,gravity=0,warp=20,warpCooldown=8,rarity="Experimental"})
gun("slingshot","Slingshot",2,"bolt",22,1,0.35,{speed=110,gravity=0.6,reload=0.35,recoil=0.2})
gun("flare_gun","Flare Gun",2,"bolt",24,1,1,{speed=100,gravity=0.35,flare=true,reload=2.8})
add("daggers","Daggers",2,"melee",{damage=20,range=4.5,width=3,interval=0.28,windup=0.1,dual=true})
local melee={
	{"knife","Knife",50,5,3,0.48,0.12}, {"katana","Katana",50,7,5,0.8,0.24},
	{"fists","Fists",18,3.8,3,0.3,0.1}, {"battle_axe","Battle Axe",65,6.5,6,1.2,0.4},
	{"maul","Maul",75,6,5,1.5,0.55}, {"spear","Spear",42,9,2,0.8,0.22},
	{"trowel","Trowel",24,4.5,3,0.38,0.1}, {"chainsaw","Chainsaw",8,4.5,3,0.13,0.04},
	{"riot_shield","Riot Shield",20,4,4,0.9,0.25}, {"scythe","Scythe",55,7.5,8,1.1,0.35}}
for _,m in ipairs(melee) do add(m[1],m[2],3,"melee",{damage=m[3],range=m[4],width=m[5],interval=m[6],windup=m[7],
	headshot=m[1]=="knife" and 1 or 1.5,continuous=m[1]=="chainsaw",heatPerShot=m[1]=="chainsaw" and 0.045 or nil,cooling=0.3,shield=m[1]=="riot_shield"}) end
-- Utility charges reset on legitimate mode/round entry, never from the client.
add("grappler","Grappler",4,"grapple",{range=85,cooldown=7,charges=20,duration=1.8})
add("medkit","Medkit",4,"heal",{heal=50,windup=2,cooldown=12,charges=2})
add("subspace_tripmine","Subspace Tripmine",4,"mine",{damage=55,radius=12,range=12,cooldown=5,charges=2,lifetime=30,limit=2,rarity="Experimental"})
add("warpstone","Warpstone",4,"warp",{range=26,cooldown=12,charges=3,rarity="Experimental"})
add("flashbang","Flashbang",4,"flash",{speed=65,gravity=1,fuse=1.6,radius=30,cooldown=5,charges=2})
add("freeze_ray","Freeze Ray",4,"freeze",{damage=5,range=30,slow=0.6,cooldown=5,charges=5,rarity="Experimental"})
add("grenade","Grenade",4,"grenade",{damage=65,speed=70,gravity=1,fuse=2,radius=15,bounce=true,cooldown=5,charges=2})
add("jump_pad","Jump Pad",4,"pad",{range=12,cooldown=8,charges=2,lifetime=25,limit=1})
add("molotov","Molotov",4,"molotov",{damage=6,speed=60,gravity=1,radius=10,lifetime=6,cooldown=8,charges=2})
add("satchel","Satchel",4,"satchel",{damage=70,range=12,radius=15,cooldown=3,charges=2,lifetime=40,limit=2})
add("smoke_grenade","Smoke Grenade",4,"smoke",{speed=65,gravity=1,fuse=1.8,radius=12,lifetime=8,bounce=true,cooldown=8,charges=2})
add("war_horn","War Horn",4,"horn",{range=30,cooldown=20,charges=2,duration=4,rarity="Signature"})
Weapons.Default={"assault_rifle","handgun","knife","medkit"}
-- Free Creator Store audio; source/permission records in docs/FREE_POLISH.md.
Weapons.ById.assault_rifle.assets.audio.fire="rbxassetid://113879008765178"
Weapons.ById.handgun.assets.audio.fire="rbxassetid://113879008765178"
Weapons.ById.knife.assets.audio.fire="rbxassetid://79992355082486"
return Weapons
