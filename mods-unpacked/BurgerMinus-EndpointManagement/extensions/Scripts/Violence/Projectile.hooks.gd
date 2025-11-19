extends Object

func _physics_process(chain: ModLoaderHookChain, delta):
	
	var projectile = chain.reference_object as Projectile
	
	var golem_boss = projectile.causality.liable_enemy_golem
	if golem_boss != null and golem_boss.golem_upgrades["euphoria"] and golem_boss.euphoria_active:
		delta *= golem_boss.euphoria_multiplier
	
	chain.execute_next([delta])
