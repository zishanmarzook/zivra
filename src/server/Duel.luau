local Duel = {}
Duel.__index = Duel

function Duel.new(players, rules, now)
	return setmetatable({
		players = players,
		rules = rules,
		phase = "Versus",
		deadline = now + rules.VersusSeconds,
		score = {0, 0},
		eliminations = {0, 0},
		rematch = {},
		round = 0,
		draws = 0,
	}, Duel)
end

function Duel:side(player)
	return table.find(self.players, player)
end

function Duel:countdown(now)
	self.round += 1
	self.phase = "Countdown"
	self.deadline = now + self.rules.CountdownSeconds
	self.roundWinner = nil
	self.reason = nil
end

function Duel:begin(now)
	self.phase = "Active"
	self.deadline = now + self.rules.RoundSeconds
end

function Duel:resolve(winner, reason, now)
	if self.phase ~= "Active" then return false end
	self.roundWinner = winner
	self.reason = reason
	if winner then
		self.score[winner] += 1
		if reason == "Elimination" then self.eliminations[winner] += 1 end
	end
	if not winner then self.draws += 1 end
	if self.draws >= self.rules.MaxDraws then
		self:finish(nil, "Draw limit", now)
	elseif winner and self.score[winner] >= self.rules.WinsRequired then
		self:finish(winner, reason, now)
	else
		self.phase = "RoundEnd"
		self.deadline = now + self.rules.IntermissionSeconds
	end
	return true
end

function Duel:finish(winner, reason, now)
	self.phase = "Result"
	self.winner = winner
	self.rematchAllowed = winner ~= nil or reason == "Draw limit"
	self.reason = reason
	self.deadline = now + self.rules.ResultSeconds
end

function Duel:timeout(firstHealth, secondHealth, now)
	local winner
	if firstHealth ~= secondHealth then winner = firstHealth > secondHealth and 1 or 2 end
	return self:resolve(winner, winner and "Time limit" or "Draw", now)
end

function Duel:vote(player)
	local side = self:side(player)
	if self.phase ~= "Result" or not side or not self.rematchAllowed then return false end
	self.rematch[side] = true
	return self.rematch[1] == true and self.rematch[2] == true
end

return Duel
