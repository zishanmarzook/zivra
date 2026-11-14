-- ZIVRA PHASE 1 M4 INSTALLER. Paste the COMPLETE Install-M4.luau into
-- Studio's Command Bar in Edit mode. Do not run this header separately.
assert(not game:GetService('RunService'):IsRunning(),'Stop Play before installing')
local ownedAttribute='ZIVRAWeaponOwned'
local replacements={
 {game.ReplicatedStorage,'ZIVRAWeapons'},
 {game.ServerScriptService,'ZIVRAWeapons'},
 {game.StarterPlayer.StarterPlayerScripts,'ZIVRAWeaponClient'},
 {game.StarterGui,'ZIVRAWeaponHUD'},
 {game.StarterPack,'ZIVRA_M4'},
}
for _,entry in replacements do
 local existing=entry[1]:FindFirstChild(entry[2])
 assert(not existing or existing:GetAttribute(ownedAttribute),'Existing unowned object: '..entry[2])
end
local history=game:GetService('ChangeHistoryService')
local recording=history:TryBeginRecording('Install ZIVRA Phase 1 M4')
local backup=Instance.new('Folder');backup.Name='ZIVRAWeaponBackup_'..os.time();backup.Parent=game.ServerStorage
for _,entry in replacements do
 local existing=entry[1]:FindFirstChild(entry[2])
 if existing then existing.Parent=backup;if existing:IsA('BaseScript') then existing.Enabled=false end end
end
local function object(class,name,parent)
 local item=Instance.new(class);item.Name=name;item:SetAttribute(ownedAttribute,true);item.Parent=parent;return item
end
local shared=object('Folder','ZIVRAWeapons',game.ReplicatedStorage)
local server=object('Folder','ZIVRAWeapons',game.ServerScriptService)
local remotes=object('Folder','WeaponRemotes',shared)
for _,name in ipairs({'Request','State','Effects'}) do object('RemoteEvent',name,remotes) end
local hud=object('ScreenGui','ZIVRAWeaponHUD',game.StarterGui);hud.ResetOnSpawn=false;hud.Enabled=false;hud.DisplayOrder=10
local sources={}
