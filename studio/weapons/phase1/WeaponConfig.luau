-- ReplicatedStorage.ZIVRAWeapons.WeaponConfig
local Config = {}
Config.Version = 1
Config.RemoteBurst = 35
Config.RemotePerSecond = 20
Config.FriendlyFire = false
Config.Weapons = {
 M4 = {
  DisplayName = 'M4 // PROTOTYPE', Automatic = true,
  Magazine = 30, Reserve = 120, FireInterval = 0.1, ReloadTime = 2.2,
  Damage = 24, HeadMultiplier = 1.75, Range = 600,
  SpreadDegrees = 0.6, MaxCameraDistance = 32,
 },
}
-- Audio is intentionally omitted until permitted asset IDs are supplied.
return Config
