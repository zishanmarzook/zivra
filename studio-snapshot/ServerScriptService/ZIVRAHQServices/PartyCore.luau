local Core={};Core.__index=Core
function Core.new()
 return setmetatable({parties={},membership={},invites={},serial=0},Core)
end
function Core:Get(id)
 local key=self.membership[id];return key and self.parties[key]
end
function Core:Create(id)
 if self:Get(id) then return self:Get(id) end
 self.serial+=1
 local p={id=self.serial,leader=id,members={id},ready={},mode='Duel',state='Idle'}
 self.parties[p.id]=p;self.membership[id]=p.id;return p
end
function Core:Cancel(p)
 if p.state=='InMatch' then return false end
 p.state='Idle';p.queuedAt=nil;return true
end
function Core:Leave(id)
 local p=self:Get(id);if not p then return true end
 if p.state=='InMatch' then return false,'Wait for the current match to end.' end
 self:Cancel(p);p.ready[id]=nil;self.membership[id]=nil
 table.remove(p.members,table.find(p.members,id))
 if #p.members==0 then self.parties[p.id]=nil
 elseif p.leader==id then table.sort(p.members);p.leader=p.members[1] end
 return true
end
function Core:Invite(actor,target,now,duration)
 local p=self:Create(actor);local other=self:Get(target)
 if p.leader~=actor or p.state~='Idle' then return false,'Only an idle party leader can invite.' end
 if actor==target or #p.members>=5 then return false,'Party is full or invite is invalid.' end
 if other and (#other.members>1 or other.state~='Idle') then return false,'Player is already in a party or queue.' end
 self.invites[target]={party=p.id,from=actor,expires=now+duration};return true
end
function Core:Accept(id,now)
 local invite=self.invites[id];self.invites[id]=nil
 local p=invite and self.parties[invite.party]
 if not p or invite.expires<now or p.state~='Idle' or #p.members>=5 then return false,'Invitation expired or party changed.' end
 local own=self:Get(id)
 if own and (#own.members>1 or own.state~='Idle') then return false,'Leave your current party first.' end
 self:Leave(id);table.insert(p.members,id);self.membership[id]=p.id;p.ready={};return true
end
function Core:Action(id,action,value,modeConfig,now)
 local p=self:Create(id)
 if action=='Leave' then return self:Leave(id) end
 if action=='Decline' then self.invites[id]=nil;return true end
 if action=='Accept' then return self:Accept(id,now) end
 if p.state=='InMatch' then return false,'This party is in a match.' end
 if action=='Ready' then
  if p.state~='Idle' then return false,'Cancel the queue before changing readiness.' end
  p.ready[id]=not p.ready[id];return true
 end
 if p.leader~=id then return false,'Only the party leader can do that.' end
 if action=='Cancel' then return self:Cancel(p) end
 if p.state~='Idle' then return false,'Cancel matchmaking first.' end
 if action=='Mode' then
  local mode=modeConfig[value]
  if not mode or not mode.Available or value=='Training' then return false,'Mode is unavailable for matchmaking.' end
  p.mode=value;p.ready={};return true
 elseif action=='Kick' then
  if value==id or self.membership[value]~=p.id then return false,'Invalid party member.' end
  return self:Leave(value)
 elseif action=='Transfer' then
  if self.membership[value]~=p.id then return false,'Player is not in this party.' end
  p.leader=value;return true
 elseif action=='Disband' then
  for _,member in table.clone(p.members) do self:Leave(member) end;return true
 elseif action=='Queue' then
  local mode=modeConfig[p.mode]
  if not mode or not mode.Available or #p.members>mode.TeamSize then return false,'Party does not fit this mode.' end
  for _,member in p.members do if not p.ready[member] then return false,'Every party member must be ready.' end end
  p.state='Searching';p.queuedAt=now;return true
 end
 return false,'Unknown party action.'
end
function Core:Disconnect(id)
 local p=self:Get(id)
 if p then if p.state=='InMatch' then p.state='Idle' end;self:Leave(id) end
 self.invites[id]=nil
 for target,invite in pairs(self.invites) do if invite.from==id then self.invites[target]=nil end end
end
-- Bounded search packs whole parties into equal teams, preserving party membership.
function Core:FindMatch(mode,size)
 local candidates={}
 for _,p in pairs(self.parties) do if p.mode==mode and p.state=='Searching' then table.insert(candidates,p) end end
 table.sort(candidates,function(a,b) return a.queuedAt==b.queuedAt and a.id<b.id or a.queuedAt<b.queuedAt end)
 local selected,assignment={},{};local found
 local function search(index,a,b)
  if a==size and b==size then found={parties=table.clone(selected),teams=table.clone(assignment)};return true end
  if index>math.min(#candidates,12) then return false end
  local p=candidates[index];local n=#p.members
  for side=1,2 do
   if (side==1 and a or b)+n<=size then
    table.insert(selected,p);assignment[p.id]=side
    if search(index+1,a+(side==1 and n or 0),b+(side==2 and n or 0)) then return true end
    table.remove(selected);assignment[p.id]=nil
   end
  end
  return search(index+1,a,b)
 end
 search(1,0,0);return found
end
return Core