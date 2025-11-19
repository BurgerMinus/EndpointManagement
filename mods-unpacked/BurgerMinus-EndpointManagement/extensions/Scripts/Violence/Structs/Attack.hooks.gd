extends Object

func apply_target_damage_modifiers(chain: ModLoaderHookChain, target):
	
	var attack := chain.reference_object as Attack
	
	if is_instance_valid(attack.causality.liable_enemy_golem) and attack.causality.liable_enemy_golem.golem_upgrades["deviance"]:
		attack.damage *= 2
	
	chain.execute_next([target])
