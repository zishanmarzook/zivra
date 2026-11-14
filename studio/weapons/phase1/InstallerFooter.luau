local function source(class,name,parent,key)
 local s=Instance.new(class);s.Name=name;s.Source=sources[key];s:SetAttribute(ownedAttribute,true);s.Parent=parent;return s
end
source('ModuleScript','WeaponConfig',shared,'WeaponConfig')
source('ModuleScript','WeaponValidation',server,'WeaponValidation')
source('ModuleScript','DamageService',server,'DamageService')
source('Script','WeaponServer',server,'WeaponServer')
source('LocalScript','ZIVRAWeaponClient',game.StarterPlayer.StarterPlayerScripts,'WeaponClient')
local tool=object('Tool','ZIVRA_M4',game.StarterPack)
tool.ToolTip='M4 Phase 1 prototype | R: reload | hold click: fire'
tool.CanBeDropped=false;tool:SetAttribute('ZIVRAWeaponId','M4')
tool.Grip=CFrame.new(0,-0.25,0.7)
local function gunPart(name,size,cf,color)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Metal;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Parent=tool;return p
end
local black=Color3.fromRGB(35,39,49)
local handle=gunPart('Handle',Vector3.new(0.48,0.6,1.9),CFrame.new(),black)
local function add(name,size,cf,color)
 local p=gunPart(name,size,cf,color or black);local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=p;weld.Parent=p;return p
end
add('Barrel',Vector3.new(0.18,0.18,1.4),CFrame.new(0,0.1,-1.6),Color3.fromRGB(90,96,106))
add('Stock',Vector3.new(0.42,0.5,1.1),CFrame.new(0,0,1.4))
add('Grip',Vector3.new(0.35,0.7,0.4),CFrame.new(0,-0.55,0.4)*CFrame.Angles(math.rad(-15),0,0))
add('Magazine',Vector3.new(0.35,0.95,0.55),CFrame.new(0,-0.7,-0.35)*CFrame.Angles(math.rad(8),0,0))
add('Sight',Vector3.new(0.2,0.26,0.3),CFrame.new(0,0.42,-0.4),Color3.fromRGB(108,85,168))
add('TriggerArea',Vector3.new(0.16,0.16,0.45),CFrame.new(0,-0.4,0.1),Color3.fromRGB(108,112,124))
local muzzle=Instance.new('Attachment');muzzle.Name='Muzzle';muzzle.Position=Vector3.new(0,0.1,-2.35);muzzle.Parent=handle
local zones=workspace:FindFirstChild('ZIVRACombatZones')
if not zones then zones=object('Folder','ZIVRACombatZones',workspace) end
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
print('ZIVRA Phase 1 installed: M4 prototype. No combat zones enabled. Lobby remains protected. Press Play and equip slot 1.')
