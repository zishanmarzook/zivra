-- ServerScriptService.ZIVRAWeapons.DamageService
local Players=game:GetService('Players')
local Config=require(game.ReplicatedStorage.ZIVRAWeapons.WeaponConfig)
local Damage={}
local function inside(cf,size,point)
 local p=cf:PointToObjectSpace(point);local s=size/2
 return math.abs(p.X)<=s.X and math.abs(p.Y)<=s.Y and math.abs(p.Z)<=s.Z
end
function Damage.InLobby(point)
 -- Lobby protection wins even when a combat zone overlaps it.
 for _,name in ipairs({'ZIVRA_Corridor','ZIVRA_Lobby'}) do
  local model=workspace:FindFirstChild(name)
  if model and model:IsA('Model') and model:FindFirstChildWhichIsA('BasePart',true) then
   local cf,size=model:GetBoundingBox()
   if inside(cf,size+Vector3.new(8,12,8),point) then return true end
  end
 end
 return false
end
function Damage.Zone(point)
 if Damage.InLobby(point) then return nil end
 local zones=workspace:FindFirstChild('ZIVRACombatZones')
 if not zones then return nil end
 for _,zone in zones:GetChildren() do
  if zone:IsA('BasePart') and zone:GetAttribute('Enabled')==true and inside(zone.CFrame,zone.Size,point) then return zone end
 end
 return nil
end
function Damage.Apply(shooter, result, spec)
 if not result then return false,false,false end
 local model=result.Instance:FindFirstAncestorOfClass('Model')
 while model and not model:FindFirstChildOfClass('Humanoid') do model=model.Parent and model.Parent:FindFirstAncestorOfClass('Model') end
 local hum=model and model:FindFirstChildOfClass('Humanoid')
 local root=model and model:FindFirstChild('HumanoidRootPart')
 local own=shooter.Character
 local ownRoot=own and own:FindFirstChild('HumanoidRootPart')
 if not hum or hum.Health<=0 or not root or not ownRoot or model==own then return false,false,false end
 if model:FindFirstChildOfClass('ForceField') then return false,false,false end
 local zone=Damage.Zone(ownRoot.Position)
 if not zone or Damage.Zone(root.Position)~=zone or Damage.Zone(result.Position)~=zone then return false,false,false end
 local victim=Players:GetPlayerFromCharacter(model)
 if victim and not Config.FriendlyFire and not shooter.Neutral and not victim.Neutral and shooter.Team~=nil and shooter.Team==victim.Team then return false,false,false end
 local head=result.Instance.Name=='Head'
 local before=hum.Health
 hum:TakeDamage(spec.Damage*(head and spec.HeadMultiplier or 1))
 return hum.Health<before,head,hum.Health<=0
end
return Damage
