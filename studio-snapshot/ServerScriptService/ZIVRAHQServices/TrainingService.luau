local Stats=require(script.Parent.SessionStats)
local T={}
local cooldown={}
function T.Hit(player,result)
 if not player:GetAttribute('ZIVRATraining') or player:GetAttribute('ZIVRAInMatch') or not result then return false,false end
 local model=result.Instance:FindFirstAncestorOfClass('Model')
 if not model or not model:GetAttribute('ZIVRATrainingTarget') or not model:IsDescendantOf(workspace.ZIVRA_Corridor.TrainingTargets) then return false,false end
 local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 if not root or root.Position.X> -42 or root.Position.Z<45 or root.Position.Z>118 or math.abs(root.Position.Y-34)>15 then return false,false end
 if (cooldown[model] or 0)>os.clock() then return false,false end
 cooldown[model]=os.clock()+0.6
 local hit=model:FindFirstChild('Bullseye')
 if hit then hit.Color=Color3.fromRGB(255,186,71);task.delay(0.6,function() if hit.Parent then hit.Color=Color3.fromRGB(0,223,255) end end) end
 return true,true
end
return T