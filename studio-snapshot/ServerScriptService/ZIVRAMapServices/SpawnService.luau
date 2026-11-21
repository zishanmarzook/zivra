local Players=game:GetService('Players')
local C=require(game.ReplicatedStorage.ZIVRAMapShared.MapConfig)
local S={}
function S.Place(player,spawn,team)
 local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
 if not h or h.Health<=0 or not root then return false end
 c:SetAttribute('ZIVRAMovementExemptUntil',workspace:GetServerTimeNow()+2)
 h.Sit=false;root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 c:PivotTo(spawn.CFrame*CFrame.new(0,3.1,0))
 player.Team=team;player.Neutral=team==nil
 if C.SpawnProtection>0 then local force=Instance.new('ForceField');force.Parent=c;game:GetService('Debris'):AddItem(force,C.SpawnProtection) end
 return true
end
function S.Lobby(player,oldTeam,neutral)
 player:SetAttribute('ZIVRAInMatch',nil);player.Team=oldTeam;player.Neutral=neutral
 local spawn=workspace:FindFirstChild('ZIVRA_Corridor') and workspace.ZIVRA_Corridor:FindFirstChild('LobbySpawn')
 if spawn and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
  local c=player.Character;c:SetAttribute('ZIVRAMovementExemptUntil',workspace:GetServerTimeNow()+2)
  c:PivotTo(spawn.CFrame*CFrame.new(0,3.1,0));c.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
 end
end
return S