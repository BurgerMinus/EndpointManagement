extends Object

func _physics_process(chain: ModLoaderHookChain, delta):
	
	var ball = chain.reference_object as EnergyBall
	
	var golem_boss = ball.causality.liable_enemy_golem
	if golem_boss != null and golem_boss.golem_upgrades["euphoria"] and golem_boss.euphoria_active:
		delta *= golem_boss.euphoria_multiplier
	
	chain.execute_next([delta])
