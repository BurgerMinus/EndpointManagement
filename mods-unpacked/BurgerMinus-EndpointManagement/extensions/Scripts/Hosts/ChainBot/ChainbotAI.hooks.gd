extends Object

# if you got hit and retracted grapple no you didnt :)
func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as ChainBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var a_g_process = Callable(ai.states[ai.States.ALLY_GRAPPLED][ai.PROCESS])
	ai.states[ai.States.ALLY_GRAPPLED][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			for event in ai.frame_events:
				if event[0] == ai.EnemyEvent.DAMAGED: event[0] = null
		a_g_process.call()
	
	var f_g_process = Callable(ai.states[ai.States.FOE_GRAPPLED][ai.PROCESS])
	ai.states[ai.States.FOE_GRAPPLED][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			for event in ai.frame_events:
				if event[0] == ai.EnemyEvent.DAMAGED: event[0] = null
		f_g_process.call()
	
	var j_e_process = Callable(ai.states[ai.States.JUGGLE_ENTITY][ai.PROCESS])
	ai.states[ai.States.JUGGLE_ENTITY][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			var temp = ai.damaged_by_player_this_frame
			ai.damaged_by_player_this_frame = false
			j_e_process.call()
			ai.damaged_by_player_this_frame = temp
		else:
			j_e_process.call()
	
	
