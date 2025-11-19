extends Object

func get_weighted_behaviour_options_for_golem(chain: ModLoaderHookChain):
	
	var ai = chain.reference_object as ShotgunBotAI
	
	var behaviors = chain.execute_next()
	
	if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
		for b in behaviors:
			if b[0] == ai.States.NAIL_DRIVER:
				b[1] *= 5
	
	return behaviors
