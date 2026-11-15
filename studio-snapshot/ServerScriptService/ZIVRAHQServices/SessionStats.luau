local S={Data={}}
function S.Get(p)
 if not S.Data[p] then S.Data[p]={Matches=0,Wins=0,Eliminations=0,Deaths=0,XP=0,Shots=0,Hits=0,Targets=0,Joined=os.clock(),Settings={ReducedMotion=false,AutoSprint=false,FOV=74},Claimed=false} end
 return S.Data[p]
end
function S.Combat(p,hit,kill)
 local d=S.Get(p);if kill then d.Eliminations+=1 end
end
function S.Training(p,hit,kill)
 local d=S.Get(p);d.Shots+=1;if hit then d.Hits+=1 end;if kill then d.Targets+=1 end
end
function S.Snapshot(p)
 local d=S.Get(p);local r=table.clone(d);r.PlaySeconds=math.floor(os.clock()-d.Joined);r.Joined=nil;r.Level=1+math.floor(d.XP/500);r.Persistence='SESSION ONLY';return r
end
return S