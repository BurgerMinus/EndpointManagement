extends Object

func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as ShotgunBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var n_d_process = Callable(ai.states[ai.States.NAIL_DRIVER][ai.PROCESS])
	ai.states[ai.States.NAIL_DRIVER][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.foe.is_player and ai.dist_to_foe < 50 and ai.body.melee_charge_timer < 0.1 and randf() < 0.5:
				ai.body.shoot()
				ai.exit_behaviour(ai.COMPLETED, 0.5)
		n_d_process.call()

func get_weighted_behaviour_options_for_golem(chain: ModLoaderHookChain):
	
	var ai = chain.reference_object as ShotgunBotAI
	
	var behaviors = chain.execute_next()
	
	if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
		if ai.behaviour_cooldowns.has(ai.States.NAIL_DRIVER):
			ai.behaviour_cooldowns.erase(ai.States.NAIL_DRIVER)
		for b in behaviors:
			match b[0]:
				ai.States.NAIL_DRIVER:
					b[1] *= 2
				ai.States.REPOSITION:
					b[1] *= 0
	
	elif not ai.behaviour_cooldowns.has(ai.States.NAIL_DRIVER):
		ai.add_behaviour_cooldown(ai.States.NAIL_DRIVER, 2.0)
	
	return behaviors
