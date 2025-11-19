extends Object

static func calculate_kill_score(chain: ModLoaderHookChain, victim, attack):
	
	if attack != null:
		
		var bonuses = attack.bonuses
		var killer = attack.causality.original_source
		var killer_alive = is_instance_valid(killer) and not (killer is Enemy and killer.dead)
		var player_controlling_killer = killer_alive and (killer.is_player or killer.enemy_golem)
		var trickshot = false
		
		if not player_controlling_killer and not killer == victim and not Fitness.Bonus.KAMIKAZE in bonuses:
				if attack.proxy_level == 0:
					trickshot = true
					bonuses.append(Fitness.Bonus.TRICKSHOT)
	
		var enemy_golem_liable = is_instance_valid(attack.causality.liable_enemy_golem)
		if enemy_golem_liable and not Fitness.Bonus.CLOSE_CALL in bonuses:
			var enemy_golem = attack.causality.liable_enemy_golem
			enemy_golem.on_trickshot(bonuses)
		if trickshot:
			bonuses.pop_back()
	
	chain.execute_next([victim, attack])
