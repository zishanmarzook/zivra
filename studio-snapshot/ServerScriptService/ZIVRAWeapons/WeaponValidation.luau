-- ServerScriptService.ZIVRAWeapons.WeaponValidation
local V = {}
function V.FiniteVector(v)
 if typeof(v) ~= 'Vector3' then return false end
 for _,n in ipairs({v.X,v.Y,v.Z}) do
  if n ~= n or math.abs(n) > 1e7 then return false end
 end
 return true
end
function V.Consume(bucket, now, burst, rate)
 bucket.tokens = math.min(burst, bucket.tokens + math.max(0,now-bucket.updated)*rate)
 bucket.updated = now
 if bucket.tokens < 1 then return false end
 bucket.tokens -= 1
 return true
end
function V.Alive(player)
 local c=player.Character
 local h=c and c:FindFirstChildOfClass('Humanoid')
 local root=c and c:FindFirstChild('HumanoidRootPart')
 if not h or h.Health<=0 or not root then return nil end
 return c,h,root
end
function V.Equipped(player)
 local c=player.Character
 if not c then return nil end
 for _,t in c:GetChildren() do
  if t:IsA('Tool') and t:GetAttribute('ZIVRAWeaponId') == 'M4' and t:GetAttribute('ZIVRAWeaponOwned') then return t end
 end
 return nil
end
function V.ValidateAim(player, tool, cameraOrigin, direction, spec)
 if not V.FiniteVector(cameraOrigin) or not V.FiniteVector(direction) then return nil end
 local length=direction.Magnitude
 if length<0.99 or length>1.01 then return nil end
 local character,_,root=V.Alive(player)
 if not character or tool.Parent~=character then return nil end
 local head=character:FindFirstChild('Head')
 if not head or (cameraOrigin-head.Position).Magnitude>spec.MaxCameraDistance then return nil end
 local handle=tool:FindFirstChild('Handle')
 local muzzle=handle and handle:FindFirstChild('Muzzle')
 if not muzzle or not muzzle:IsA('Attachment') then return nil end
 local origin=muzzle.WorldPosition
 if (origin-root.Position).Magnitude>9 then return nil end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character};params.RespectCanCollide=true
 -- A gun poking through a wall must not fire from its far side.
 local path=origin-head.Position
 if path.Magnitude>0.01 and workspace:Raycast(head.Position,path,params) then return nil end
 -- Reject third-person cameras positioned through world geometry.
 local cameraPath=cameraOrigin-head.Position
 if cameraPath.Magnitude>1 and workspace:Raycast(head.Position,cameraPath,params) then return nil end
 local aimHit=workspace:Raycast(cameraOrigin,direction.Unit*spec.Range,params)
 local target=aimHit and aimHit.Position or cameraOrigin+direction.Unit*spec.Range
 local delta=target-origin
 if delta.Magnitude<0.05 then return nil end
 return origin,delta.Unit,params
end
return V

