extends Object

func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as FlameBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var s_a_enter = Callable(ai.states[ai.States.SEAR_ALLY][ai.ENTER])
	ai.states[ai.States.SEAR_ALLY][ai.ENTER] = func():
		s_a_enter.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if randf() > 0.5 and ai.body.swap_shield_health/ai.body.max_swap_shield_health > 0.4:
				ai.sear_target = GameManager.player.true_host
