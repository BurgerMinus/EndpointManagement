extends Object

func initialize(chain: ModLoaderHookChain, body_, starting_conditions = null):
	
	var ai = chain.reference_object as SaberBotAI
	
	chain.execute_next([body_, starting_conditions])
	
	var c_process = Callable(ai.states[ai.States.CIRCLE][ai.PROCESS])
	ai.states[ai.States.CIRCLE][ai.PROCESS] = func():
		c_process.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.can_approach_for_slash() and ai.dist_to_foe < 150 and randf() < ai.delta:
				ai.set_state(ai.States.PREP_SLASH)
	
	var c_i_process = Callable(ai.states[ai.States.CIRCLE_IN][ai.PROCESS])
	ai.states[ai.States.CIRCLE_IN][ai.PROCESS] = func():
		c_i_process.call()
		if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
			if ai.can_approach_for_slash() and ai.dist_to_foe < 150 and randf() < ai.delta:
				ai.set_state(ai.States.PREP_SLASH)

# attempt to deflect projectiles, otherwise aim at player
func handle_hovering_sword(chain: ModLoaderHookChain, delta):
	
	var ai = chain.reference_object as SaberBotAI
	
	if ai.body.enemy_golem != null and ai.body.enemy_golem.adv_host_ai and ai.AI_level >= 3:
		var saber_dir = ai.dir_to_foe
		
		var space_state = ai.get_world_2d().direct_space_state
		
		var query = PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 6
		query.transform = ai.global_transform
		var shape = CircleShape2D.new()
		shape.radius = ai.body.saber_range * 1.5
		query.set_shape(shape)
		
		var results = space_state.intersect_shape(query, 512)
		var candidates = []
		for col in results:
			if col['collider'].is_in_group("hitbox"):
				pass
			else:
				var bullet
				var hit_object = col['collider']
				if hit_object.has_method('take_damage'):
					bullet = hit_object
				elif hit_object.get_parent().has_method('take_damage'):
					bullet = hit_object.get_parent()
				else:
					continue
				if bullet is Projectile and bullet not in candidates:
					candidates.append(bullet)
		var valid_candidates = []
		for c in candidates:
			var causality = c.causality
			if Causality.is_owned_by_player(causality):
				valid_candidates.append(c)
		candidates = valid_candidates.duplicate(true)
		valid_candidates.clear()
		for c in candidates:
			var attack_angle_diff = c.velocity.angle_to(c.global_position.direction_to(ai.body.global_position))
			if c.velocity.length() > 10 and attack_angle_diff < PI/15.0:
				valid_candidates.append(c)
		if not valid_candidates.is_empty() and ai.body.saber != null:
			var saber_pos = ai.body.saber.global_position
			valid_candidates.sort_custom(func(a, b): return a.global_position.distance_squared_to(saber_pos) < b.global_position.distance_squared_to(saber_pos))
			saber_dir = ai.body.global_position.direction_to(valid_candidates[0].global_position)
		
		ai.set_saber_target_point(ai.global_position + saber_dir.normalized()*0.5*ai.body.saber_range)
	
	else:
		chain.execute_next([delta])
