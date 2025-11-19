extends Object

# unga bunga
func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as BatBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var m_exit
	if ai.states[ai.State.MELEE].has(ai.EXIT):
		m_exit = Callable(ai.states[ai.State.MELEE][ai.EXIT])
	else:
		m_exit = func():
			pass
	ai.states[ai.State.MELEE][ai.EXIT] = func():
		m_exit.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.state_counter > 0:
				ai.set_state_delayed(ai.State.POSITION_FOR_MELEE, 0.25)
	
	var p_f_m_enter = Callable(ai.states[ai.State.POSITION_FOR_MELEE][ai.ENTER])
	ai.states[ai.State.POSITION_FOR_MELEE][ai.ENTER] = func():
		p_f_m_enter.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.state_counter > 0:
				print(str(ai.state_counter) + " " + str(ai.state_timer))
				ai.state_counter -= 1
				ai.state_timer *= 0.1
	
	var p_f_m_process = Callable(ai.states[ai.State.POSITION_FOR_MELEE][ai.PROCESS])
	ai.states[ai.State.POSITION_FOR_MELEE][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.state_counter > 0 and ai.state_timer < 0:
				ai.set_state(ai.State.MELEE)
		p_f_m_process.call()

func get_weighted_behaviour_options_for_golem(chain: ModLoaderHookChain):
	
	var ai = chain.reference_object as BatBotAI
	
	ai.state_counter = randi() % 5
	var behaviors = chain.execute_next()
#	if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
#		for b in behaviors:
#			if b[0] == ai.State.POSITION_FOR_MELEE:
#				b[1] *= 2
	
	return behaviors
