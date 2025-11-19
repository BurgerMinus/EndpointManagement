extends Object

func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as WheelBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var d_process = Callable(ai.states[ai.States.DRIFT][ai.PROCESS])
	ai.states[ai.States.DRIFT][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.damaged_by_player_this_frame:
				ai.set_state(ai.States.REAL_SNIPE)
		d_process.call()
