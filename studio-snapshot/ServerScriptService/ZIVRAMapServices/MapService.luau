local Shared=game.ReplicatedStorage.ZIVRAMapShared
local C=require(Shared.MapConfig)
local S={Active=nil}
function S.Eligible(mode)
 mode=C.ModeAliases[mode] or mode
 local result={}
 for id,spec in pairs(C.Maps) do if table.find(spec.Modes,mode) and game.ServerStorage.ZIVRAMaps:FindFirstChild(id) then table.insert(result,id) end end
 table.sort(result);return result
end
function S.Validate(model)
 local report={};local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={model.Geometry};params.RespectCanCollide=true
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={model.Geometry};overlap.RespectCanCollide=true
 for _,spawn in model.Spawns:GetChildren() do
  local standing=spawn.Position+Vector3.new(0,3.1,0)
  local floor=workspace:Raycast(spawn.Position+Vector3.new(0,5,0),Vector3.new(0,-9,0),params)
  local blockers=workspace:GetPartBoundsInBox(CFrame.new(standing),Vector3.new(4,5.8,4),overlap)
  if not floor or floor.Normal.Y<0.7 or #blockers>0 then table.insert(report,spawn.Name..': unsafe clearance/floor') end
 end
 return #report==0,report
end
function S.Load(id)
 assert(not S.Active,'Another competitive map is already active')
 assert(C.Maps[id],'Unknown map')
 local template=game.ServerStorage.ZIVRAMaps:FindFirstChild(id);assert(template,'Missing geometry for '..id)
 local preview=workspace:FindFirstChild('ZIVRAMapPreview');if preview then preview:Destroy() end
 local model=template:Clone();model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model.WorldPivot=CFrame.identity;model:PivotTo(C.Origin);model.Name='ZIVRAActiveMap';model.Parent=workspace
 local ok,problems=S.Validate(model)
 if not ok then model:Destroy();error(table.concat(problems,', ')) end
 local zones=workspace:FindFirstChild('ZIVRACombatZones')
 if not zones then zones=Instance.new('Folder');zones.Name='ZIVRACombatZones';zones.Parent=workspace end
 local zone=Instance.new('Part');zone.Name='ZIVRAActiveMapZone';zone.Size=Vector3.new(C.Maps[id].Size.X,100,C.Maps[id].Size.Y);zone.CFrame=C.Origin*CFrame.new(0,35,0);zone.Anchored=true;zone.Transparency=1;zone.CanCollide=false;zone.CanQuery=false;zone.CanTouch=false;zone:SetAttribute('Enabled',false);zone.Parent=zones
 S.Active={Id=id,Model=model,Zone=zone}
 return S.Active
end
function S.Unload()
 if S.Active then S.Active.Zone:Destroy();S.Active.Model:Destroy();S.Active=nil end
end
return S