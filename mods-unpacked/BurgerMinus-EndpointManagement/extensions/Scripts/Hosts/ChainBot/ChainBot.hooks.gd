extends Object

# surely there is a way to call enemy.take_damage from here but i havent found it yet
func take_damage(chain: ModLoaderHookChain, attack):
	
	var deadlift = chain.reference_object as ChainBot
	
	if deadlift.enemy_golem != null and deadlift.enemy_golem.adv_host_ai and deadlift.AI.AI_level >= 3:
		if deadlift.has_grappled_entity() and deadlift.tug_timer > 0.0 and is_instance_valid(attack.causality.original_source) and deadlift.grapple.anchor_entity == attack.causality.original_source:
			attack.bonuses.append(Fitness.Bonus.JOUST)
		
		deadlift.effect_system.apply_damage_effects(attack)
	
		if attack.damage == 0.0 and attack.get_impulse_on(deadlift).length_squared() == 0.0: return
		deadlift.on_damage_taken.emit(deadlift, attack)
		deadlift.flash()
			
		if deadlift.spawn_state == deadlift.SpawnState.SPAWNING_INTERRUPTIBLE:
			deadlift.finish_spawning()
			
		if deadlift.has_node('EntityProjectilizer'):
			deadlift.handle_projectilized_entity_deflection(attack)
		
		if deadlift.swap_shield_health > 0:
			var shield_damage = min(deadlift.swap_shield_health, attack.damage)
			deadlift.swap_shield_health -= shield_damage
			attack.damage = 0
			if deadlift.swap_shield_health <= 1:
				deadlift.swap_shield_health = 0
				deadlift.shield_broken_audio.play()
				
			deadlift.update_swap_shield()
		
		deadlift.velocity += attack.get_impulse_on(deadlift)
			
		attack.stun -= deadlift.stun_resist
		if attack.stun > 0:
			deadlift.stun(attack.stun)
			
		elif is_instance_valid(deadlift.AI) and deadlift.AI is EnemyAI:
			deadlift.AI.add_frame_event([deadlift.AI.EnemyEvent.DAMAGED, attack])
			Progression.on_enemy_damaged(attack)
		
		deadlift.emit_blood(attack)
		deadlift.health -= attack.damage
		
		
		if deadlift.health <= 0:
			deadlift.healthbar.value = 0
			deadlift.die(attack)
	else:
		chain.execute_next([attack])
