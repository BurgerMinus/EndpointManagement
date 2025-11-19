extends Object

func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as ShieldBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var r_process = Callable(ai.states[ai.States.RETALIATE][ai.PROCESS])
	ai.states[ai.States.RETALIATE][ai.PROCESS] = func():
		r_process.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			ai.delayed_foe_pos += 0.1*(ai.foe_pos - ai.delayed_foe_pos)
	
	var t_process = Callable(ai.states[ai.States.TACKLE][ai.PROCESS])
	ai.states[ai.States.TACKLE][ai.PROCESS] = func():
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			for event in ai.frame_events:
				if event[0] == ai.EnemyEvent.DAMAGED: event[0] = null
		t_process.call()

func get_ally_to_tackle(chain: ModLoaderHookChain):
	
	var ai = chain.reference_object as ShieldBotAI
	
	var candidate = chain.execute_next()
	
	if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
		var candidates = ai.get_enemies_in_radius(100)
		var valid = []
		for c in candidates:
			if not c.is_player:
				valid.append(c)
				
		if not valid.is_empty(): 
			valid.sort_custom(func(a, b): return a.health < b.health)
			if valid[0].health < ai.body.tackle_damage:
				candidate = valid[0]
	
	return candidate
