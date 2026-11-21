local Models=require(game.ReplicatedStorage.ZIVRA.Models)
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Held={}
function Held.equip(player,id)
	local character=player.Character; if not character then return end
	local old=character:FindFirstChild("ZIVRA_Held"); if old then old:Destroy() end
	local hand=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not hand then return end
	local model=Models.build(Weapons.ById[id],false); model.Name="ZIVRA_Held"
	model:ScaleTo(0.8); model:PivotTo(hand.CFrame*CFrame.new(0,-0.2,-0.5)*CFrame.Angles(-math.pi/2,0,0))
	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored=false; p.Massless=true
			local weld=Instance.new("WeldConstraint"); weld.Part0=hand; weld.Part1=p; weld.Parent=p
		end
	end
	model.Parent=character
end
return Held
