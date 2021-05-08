kill_assist = {}

local kill_assists = {}

function kill_assist.clear_assists(player)
	if type(player) == "string" then
		kill_assists[player] = nil
	else
		kill_assists = {}
	end
end

function kill_assist.add_assist(victim, attacker, damage)
	if victim == attacker then return end

	if not kill_assists[victim] then
		kill_assists[victim] = {}
	end

	kill_assists[victim][attacker] = (kill_assists[victim][attacker] or 0) + damage
end

function kill_assist.reward_assists(victim, killer, reward)
	local hp = minetest.get_player_by_name(victim):get_hp()
	kill_assist.add_assist(victim, killer, hp)

	local kill_assists1 = {}
	local all_damage = 0
	for name, damage in pairs(kill_assists[victim]) do
		if minetest.get_player_by_name(name) then
			all_damage = all_damage + damage
			kill_assists1[name] = damage
		end
	end

	local kill_assists2 = {}
	local counted_damage = 0
	for name, damage in pairs(kill_assists1) do
		if name == killer or damage / all_damage >= 0.33 then
			counted_damage = counted_damage + damage
			kill_assists2[name] = damage
		end
	end

	for name, damage in pairs(kill_assists2) do
		reward = math.max(math.floor(reward * damage * 100 / counted_damage) / 100, 1)

		local main, match = ctf_stats.player(name)
		match.score = match.score + reward
		main.score = main.score + reward

		local color = "0x00FFFF"
		if name == killer then
			color = "0x00FF00"
		end

		hud_score.new(name, {
			name = "kill_assist:score",
			color = color,
			value = reward
		})
	end

	ctf_stats.request_save()
	kill_assist.clear_assists(victim)
end

ctf.register_on_killedplayer(function(victim, killer, _, toolcaps)
	if victim == killer then
		return
	end

	local reward = ctf_stats.calculateKillReward(victim, killer, toolcaps)
	reward = math.floor(reward * 100) / 100
	kill_assist.reward_assists(victim, killer, reward)
end)

ctf.register_on_attack(function(player, hitter, _, _, _, damage)
	kill_assist.add_assist(player:get_player_name(), hitter:get_player_name(), damage)
end)

ctf_match.register_on_new_match(function()
	kill_assist.clear_assists()
end)
ctf.register_on_new_game(function()
	kill_assist.clear_assists()
end)
minetest.register_on_leaveplayer(function(player)
	kill_assist.clear_assists(player)
end)
