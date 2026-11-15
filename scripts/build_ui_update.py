import json
from pathlib import Path
r=Path('.');old=json.loads(Path('docs/STUDIO_SOURCE_BASELINE.json').read_text(encoding='utf-8'))
pairs=[('ReplicatedStorage.ZIVRA.Theme','src/shared/Theme.luau'),('ReplicatedStorage.ZIVRAHQ.UIComponents','studio-snapshot/ReplicatedStorage/ZIVRAHQ/UIComponents.luau'),('StarterPlayer.StarterPlayerScripts.ZIVRAHQClient','studio-snapshot/StarterPlayer/StarterPlayerScripts/ZIVRAHQClient.client.luau'),('StarterPlayer.StarterPlayerScripts.ZIVRA_Client','src/client/init.client.luau'),('StarterPlayer.StarterPlayerScripts.ZIVRA_Client.UI','src/client/UI.luau')]
pairs+=[('ReplicatedStorage.ZIVRA.MatchAdapter', 'src/shared/MatchAdapter.luau'), ('ServerScriptService.ZIVRAMapServices.RoundService', 'studio-snapshot/ServerScriptService/ZIVRAMapServices/RoundService.luau'), ('StarterPlayer.StarterPlayerScripts.ZIVRAWeaponClient', 'studio-snapshot/StarterPlayer/StarterPlayerScripts/ZIVRAWeaponClient.client.luau'), ('StarterGui.ZIVRALobbyUI.LobbyClient', 'studio-snapshot/StarterGui/ZIVRALobbyUI/LobbyClient.client.luau')]
def q(s):
 eq='='
 while ']'+eq+']' in s:eq+='='
 return '['+eq+'[\n'+s+']'+eq+']'
entries=[]
for p,f in pairs:entries.append('{path='+q(p)+',beforeBytes='+str(old[p]['bytes'])+',beforeHash='+str(old[p]['hash'])+',after='+q(Path(f).read_text(encoding='utf-8'))+'}')
s='''-- Generated selective update for the audited ZIVRA place. No geometry changes.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before applying")
assert(game.PlaceId==121932020544473,"This patch targets the audited ZIVRA place")
local entries={
'''+',\n'.join(entries)+'''
}
local function find(path)
 local x=game
 for name in string.gmatch(path,"[^.]+") do x=x:FindFirstChild(name);assert(x,"Missing "..path) end
 return x
end
local function unchanged(source,e)
 local h=0
 for i=1,#source do h=(h*31+string.byte(source,i))%2147483647 end
 return #source==e.beforeBytes and h==e.beforeHash
end
for _,e in ipairs(entries) do
 e.instance=find(e.path)
 assert(unchanged(e.instance.Source,e) or e.instance.Source==e.after,"Source changed since audit: "..e.path..". Reconcile before updating.")
end
local history=game:GetService("ChangeHistoryService")
local recording=history:TryBeginRecording("ZIVRAReviewedUIPatch")
local backup=Instance.new("Folder");backup.Name="ZIVRA_UI_Recovery_"..os.time();backup.Parent=game.ServerStorage
for _,e in ipairs(entries) do
 if e.instance.Source~=e.after then
  local clone=e.instance:Clone();clone:SetAttribute("OriginalPath",e.path)
  if clone:IsA("BaseScript") then clone.Enabled=false end
  clone.Parent=backup;e.instance.Source=e.after
 end
end
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
print("ZIVRA UI update applied. Play-test before saving. No live publication performed.")
'''
Path('studio/UpdateAuditedUI.lua').write_text(s,encoding='utf-8')
