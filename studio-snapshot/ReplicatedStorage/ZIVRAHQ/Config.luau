return {
 InviteSeconds=45, MaxParty=5, QueueInterval=1,
 Modes={
 {Id='Duel',Name='1V1 DUEL',Players=2,TeamSize=1,Available=true,Description='One opponent. Two arenas. Win the elimination round.'},
 {Id='Team',Name='2V2 DUO ARENA',Players=4,TeamSize=2,Available=true,Description='Queue with a friend or find a teammate in this server.'},
 {Id='Skirmish',Name='3V3 TEAM SKIRMISH',Players=6,TeamSize=3,Available=false,Description='Unavailable: medium maps and six-player rounds are not installed.'},
 {Id='Battle',Name='5V5 TEAM BATTLE',Players=10,TeamSize=5,Available=false,Description='Unavailable: large maps and ten-player rounds are not installed.'},
 {Id='Zombie',Name='ZOMBIE APOCALYPSE',Players=4,TeamSize=4,Available=false,Description='Unavailable: zombie waves and survival maps are not installed.'},
 {Id='Training',Name='TRAINING',Players=1,TeamSize=1,Available=true,Description='Practice with the real M4. Training never grants competitive XP.'},
 {Id='Private',Name='PRIVATE MATCH',Players=2,TeamSize=1,Available=false,Description='Private host lobbies are not installed yet.'},
 },
}