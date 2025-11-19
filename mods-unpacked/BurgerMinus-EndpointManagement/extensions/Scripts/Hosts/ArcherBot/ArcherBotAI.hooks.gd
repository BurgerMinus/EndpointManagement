extends Object

func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as ArcherBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var b_enter = Callable(ai.states[ai.State.BOMB][ai.ENTER])
	ai.states[ai.State.BOMB][ai.ENTER] = func():
		b_enter.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			while ai.allies_to_shoot.size() < 3:
				if randf() < 1:
					ai.allies_to_shoot.append(GameManager.player.true_host)
				else:
					break
			ai.allies_to_shoot.shuffle()
