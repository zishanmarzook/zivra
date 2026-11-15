local TeleportService=game:GetService('TeleportService')
local Adapter={}
function Adapter.Start(spec,players)
 if not spec.DestinationPlaceId or spec.DestinationPlaceId<=0 then
  return require(game.ServerScriptService.ZIVRAMapServices.RoundService).Start(spec,players)
 end
 local options=Instance.new('TeleportOptions');options.ShouldReserveServer=true
 options:SetTeleportData({Mode=spec.Id})
 local ok,err=pcall(function() TeleportService:TeleportAsync(spec.DestinationPlaceId,players,options) end)
 if not ok then warn('ZIVRA teleport:',err);return false,'TELEPORT FAILED â€” TRY AGAIN' end
 return true,'DEPARTING'
end
return Adapter
