local Duel = require("../src/server/Duel")
local Config = require("../src/shared/Config")
local Weapons = require("../src/shared/Weapons")
local Rules = require("../src/shared/Rules")
local count = 0
local function check(value, message)
	count += 1
	assert(value, message)
end

local rules = Config.Duel
local a, b = {}, {}
local match = Duel.new({a, b}, rules, 10)
check(match.phase == "Versus" and match.deadline == 12, "Starts with a versus screen")
check(match:side({}) == nil, "A bystander has no side")
check(not match:resolve(1, "Elimination", 11), "A countdown cannot be scored")
check(not match:vote(a), "No rematch vote before the result")
match:countdown(12)
check(match.round == 1 and match.phase == "Countdown" and match.deadline == 15, "Countdown lasts three seconds")
match:begin(15)
check(match.phase == "Active" and match.deadline == 105, "Round lasts ninety seconds")
check(match:timeout(66, 83, 105) and match.score[2] == 1, "Remaining health wins a timed round")
check(match.eliminations[2] == 0, "A time limit does not count as an elimination")
check(not match:resolve(2, "Elimination", 106), "Duplicate outcome is ignored")
match:countdown(108)
match:begin(111)
check(match:timeout(100, 100, 201) and match.score[1] == 0 and match.score[2] == 1, "Tied health replays without scoring")
for i = 1, 3 do
	match:countdown(210 + i * 10)
	match:begin(213 + i * 10)
	check(match:resolve(1, "Elimination", 214 + i * 10), "Each active round scores")
end
check(match.phase == "Result" and match.winner == 1 and match.score[1] == 3, "First to three wins")
check(match.eliminations[1] == 3, "Result counts eliminations only")
check(not match:vote({}), "Bystander cannot vote")
check(not match:vote(a) and not match:vote(a), "One player cannot vote for both")
check(match:vote(b), "Both participants request a fresh match")

local cancelled = Duel.new({a, b}, rules, 20)
cancelled:finish(nil, "Opponent disconnected", 21)
check(cancelled.phase == "Result" and not cancelled.winner and not cancelled:vote(a), "Disconnect cancels without a win or rematch")

local draws = Duel.new({a, b}, rules, 0)
for i = 1, rules.MaxDraws do
	draws:countdown(i * 100)
	draws:begin(i * 100 + 3)
	draws:timeout(100, 100, i * 100 + 93)
end
check(draws.phase == "Result" and not draws.winner and draws.rematchAllowed, "Repeated ties end in a mutual-rematch result")

local sniper = Weapons.ById.sniper_rifle
check(Rules.hitDamage(sniper, 80, false) == 55, "Sniper torso damage")
check(Rules.hitDamage(sniper, 80, true) == 110, "Sniper headshot damage")
local shotgun = Weapons.ById.shotgun
check(shotgun.pellets * Rules.hitDamage(shotgun, 15, false) == 22, "One centered shell has 22 total body damage")
check(shotgun.pellets * Rules.hitDamage(shotgun, 65, false) < 10, "Shotgun falls off at range")
print("PASS", count, "duel lifecycle and launch balance assertions")
