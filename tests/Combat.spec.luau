local total=0
local function check(x,message) total+=1; assert(x,message) end
local events={}
Combat.init({FireClient=function(_,p,k,v) table.insert(events,{k,v}) end,FireAllClients=function() end},{Targets={}},{daily=function(p) return p.daily end})
local function player()
	local h={Health=100,MaxHealth=100,MoveDirection=Vector3.zero,FloorMaterial=0}
	local root={Position=Vector3.new(0,5,0)}; local head={Position=Vector3.new(0,7,0)}
	local c={FindFirstChildOfClass=function(_,name) return name=="Humanoid" and h end,FindFirstChild=function(_,name) return name=="Head" and head or name=="HumanoidRootPart" and root end}
	return {Character=c,UserId=1},h
end
local p,h=player()
local profile={loadout=table.clone(W.Default),owned={assault_rifle=true,handgun=true,knife=true,medkit=true},daily={},settings={},currency=0}
Combat.add(p,profile,false); Combat.reset(p); advance(1)
local s=Combat.States[p]; local dir=Vector3.new(0,0,-1)
Combat.fire(p,dir); check(s.ammo.assault_rifle==30,"Lobby cannot fire")
s.mode="Range"
Combat.fire(p,dir); check(s.ammo.assault_rifle==29,"Accepted fire consumes exactly one round")
Combat.fire(p,dir); check(s.ammo.assault_rifle==29,"Same-tick spam rejected")
advance(0.11); Combat.fire(p,dir); check(s.ammo.assault_rifle==28,"Next legal shot")
Combat.reload(p); check(events[#events][2].reloading==true,"Reload snapshot identifies reload state"); Combat.fire(p,dir); check(s.ammo.assault_rifle==28,"Firing during reload rejected")
advance(2); check(s.ammo.assault_rifle==30 and s.reserve.assault_rifle==118,"Reload conserves ammo")
check(events[#events][2].reloading==false,"Completed reload clears replicated state")
Combat.fire(p,dir); Combat.reload(p); Combat.equip(p,"handgun"); advance(2)
check(s.ammo.assault_rifle==29,"Switch cancels pending reload")
check(events[#events][2].reloading==false,"Switch clears replicated reload state")
Combat.equip(p,"assault_rifle"); advance(1); Combat.reload(p); h.Health=0; advance(2)
check(s.ammo.assault_rifle==29,"Death cancels pending reload")
h.Health=100; s.busy=0; s.menu=true; Combat.fire(p,dir)
check(s.ammo.assault_rifle==29,"Menu blocks firing"); s.menu=false
Combat.equip(p,"rpg"); check(s.loadout[1]=="rpg","Range trial equips")
check(profile.loadout[1]=="assault_rifle" and not profile.owned.rpg,"Trial never mutates persisted inventory")
s.mode="Lobby"; Combat.equip(p,"minigun"); check(s.loadout[1]=="rpg","Locked lobby equip rejected")
s.mode="Range"; Combat.equip(p,"assault_rifle"); advance(1); s.ammo.assault_rifle=0; Combat.fire(p,dir)
check(s.ammo.assault_rifle==0,"Empty magazine cannot fire")
Combat.equip(p,"minigun"); advance(1); Combat.fire(p,dir)
check(s.ammo.minigun==120,"Minigun cannot skip spinup")
Combat.trigger(p,true); advance(0.71); Combat.fire(p,dir)
check(s.ammo.minigun==119,"Minigun fires after spinup")
s.heat=1; s.overheated=true; Combat.equip(p,"assault_rifle"); advance(1); s.ammo.assault_rifle=10; Combat.fire(p,dir)
check(s.ammo.assault_rifle==10,"Switch cannot bypass overheat")
s.heat=0; s.overheated=false
local launches={}
Combat.Projectiles={launch=function(_,_,_,d,charge) table.insert(launches,{id=d.id,charge=charge}) end}
Combat.equip(p,"bow"); advance(1); Combat.fire(p,dir,true)
check(#launches==0,"Unstarted bow charge rejected")
Combat.trigger(p,true); advance(0.55); Combat.fire(p,dir,true)
check(#launches==1 and math.abs(launches[1].charge-0.5)<0.001,"Charge uses server elapsed time")
Combat.fire(p,dir,true); check(#launches==1,"Bow release cannot replay")
check(Combat.direction(Vector3.new(0/0,0,0))==nil,"NaN vector rejected")
check(Combat.direction(Vector3.new(100,0,0))==nil,"Oversized direction rejected")
check(Combat.direction("hit this player")==nil,"Wrong payload type rejected")
check(Combat.direction(dir)~=nil,"Valid aim accepted")
Utility.init(Combat); Combat.Utility=Utility
Combat.equip(p,"medkit"); advance(1); h.Health=30; Utility.activate(p,dir)
check(s.charges.medkit==1,"Heal consumes charge once")
Utility.activate(p,dir); check(s.charges.medkit==1,"Heal cooldown enforced")
advance(2.1); check(h.Health==80,"Medkit heals 50")
advance(12); Utility.activate(p,dir); advance(2.1); check(h.Health==100,"Healing capped at MaxHealth")
s.charges.medkit=2; s.cooldowns.medkit=0; h.Health=30; Utility.activate(p,dir); advance(1); s.lastHit=clock; advance(1.1)
check(h.Health==30,"Incoming damage interrupts heal")
s.cooldowns.medkit=0; s.busy=0; Utility.activate(p,dir); Combat.equip(p,"handgun"); advance(3)
check(h.Health==30,"Switch cancels heal completion")
local other={}; Combat.Shots={{owner=p},{owner=other},{owner=p}}
local destroyed=false
Combat.Deployments={{owner=p,part={Destroy=function() destroyed=true end}}}
Combat.cleanup(p)
check(#Combat.Shots==3 and Combat.Shots[1].cancelled and Combat.Shots[3].cancelled,"Round cleanup must not mutate the projectile array inside a lethal-hit iteration")
check(not Combat.Shots[2].cancelled,"Cleanup cannot cancel another player's shots")
check(#Combat.Deployments==1 and Combat.Deployments[1].cancelled and destroyed,"Deployment cleanup marks cancellation while removing its physical object")

local duelId={}
local victim,victimHealth=player()
local victimProfile={loadout=table.clone(W.Default),owned=table.clone(profile.owned),daily={},settings={},stats={kills=0},currency=0}
Combat.add(victim,victimProfile,false)
local opposing=Combat.States[victim]
victim.Character.GetAttribute=function() return nil end
victimHealth.TakeDamage=function(self,amount) self.Health=math.max(0,self.Health-amount) end
Players.GetPlayerFromCharacter=function(_,model) return model==victim.Character and victim or nil end
local hitPart={Name="UpperTorso",Position=Vector3.new(0,7,-15),
	FindFirstAncestorOfClass=function() return victim.Character end}
workspace.Raycast=function() return {Instance=hitPart,Position=hitPart.Position} end

s.mode="Duel"
s.duel={id=duelId,phase="Countdown"}
s.loadout[1]="shotgun"
s.slot=1
opposing.mode="Duel"
opposing.duel={id=duelId,phase="Countdown"}
Combat.reset(p)
advance(1)
Combat.fire(p,dir)
check(s.ammo.shotgun==6 and victimHealth.Health==100,"Countdown rejects fire before consuming ammo")
s.duel.phase="Active"
opposing.duel.phase="Active"
Combat.fire(p,dir)
check(s.ammo.shotgun==5 and victimHealth.Health==78,"One shell consumes one round and aggregates eight pellet hits")
local hitCount=0
for _,event in ipairs(events) do if event[1]=="Hit" then hitCount+=1 end end
check(hitCount==1,"Pellets produce one hit confirmation for the target")

opposing.duel.id={}
advance(1)
Combat.fire(p,dir)
check(victimHealth.Health==78,"A player in a separate match takes no damage")
opposing.duel.id=duelId
opposing.duel.phase="RoundEnd"
advance(1)
Combat.fire(p,dir)
check(victimHealth.Health==78,"A target in an ended round takes no damage")

opposing.duel.phase="Active"
s.loadout[1]="sniper_rifle"
Combat.reset(p)
advance(1)
victimHealth.Health=100
Combat.fire(p,dir)
check(victimHealth.Health==45,"The sniper delivers 55 torso damage at test distance")
advance(1.4)
victimHealth.Health=100
hitPart.Name="Head"
profile.daily.kills=0
profile.stats={kills=0}
Combat.fire(p,dir)
check(victimHealth.Health==0 and profile.stats.kills==1,"A direct sniper headshot eliminates once")
print("PASS",total,"combat lifecycle assertions with mocked engine")
