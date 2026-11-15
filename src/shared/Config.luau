return {
 Countdown=10, ScanInterval=0.2, DepartureCooldown=5,
 -- Set DestinationPlaceId only after the corresponding map exists.
 Stations={
  {Id='Duel',Label='1v1 DUEL',Capacity=2,DestinationPlaceId=0},
  {Id='Team',Label='2v2 TEAM BATTLE',Capacity=4,DestinationPlaceId=0},
  {Id='Squad',Label='4-PLAYER SQUAD',Capacity=4,DestinationPlaceId=0},
  {Id='Zombie',Label='ZOMBIE APOCALYPSE',Capacity=4,DestinationPlaceId=0},
  {Id='Horror',Label='HORROR SURVIVAL',Capacity=4,DestinationPlaceId=0},
  {Id='FFA',Label='FREE-FOR-ALL',Capacity=8,DestinationPlaceId=0},
 },
 -- Supply an audio asset you have permission to use. Zero disables ambience.
 AmbientSoundId=0, AmbientVolume=0.12,
}
