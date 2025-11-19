extends Object

func initialize(chain: ModLoaderHookChain, boss = null):
	
	var controller := chain.reference_object as CityBossOrbController
	
	chain.execute_next([boss])
	
	# scale laser cage with game speed
	var base_l_c_process = Callable(controller.states[controller.State.LASER_CAGE][controller.PROCESS])
	controller.states[controller.State.LASER_CAGE][controller.PROCESS] = func():
		controller.pattern_rot += controller.pattern_rot_vel*controller.delta*(GameManager.time_manager.enemy_timescale - 1)
		if controller.state_counter == 1:
			var t = sin(controller.pattern_timer*PI/2.5)
			controller.pattern_speed = 75*sqrt(t) if t > 0 else 0
			controller.anchor_pos += controller.pattern_direction*controller.pattern_speed*controller.delta*(GameManager.time_manager.enemy_timescale - 1)
		base_l_c_process.call()
	
	# scale laser disc with game speed
	var base_l_d_process = Callable(controller.states[controller.State.LASER_DISC][controller.PROCESS])
	controller.states[controller.State.LASER_DISC][controller.PROCESS] = func():
		controller.pattern_rot += controller.pattern_rot_vel*controller.delta*(GameManager.time_manager.enemy_timescale - 1)
		if controller.state_counter == 0:
			controller.pattern_rot_vel += controller.delta * (GameManager.time_manager.enemy_timescale - 1) * 5
		elif controller.state_counter == 1:
			controller.pattern_speed = 400 * smoothstep(0.0, 1.25, controller.pattern_timer) * (GameManager.time_manager.enemy_timescale - 1)
			controller.anchor_pos += controller.pattern_direction*controller.pattern_speed*controller.delta
		base_l_d_process.call()
	
	if controller.boss.AI.em2: # single orb attacks
		
		controller.states[controller.boss.AI.EM2_State.LASER_SWIPE] = { 
			controller.ENTER: func():
				controller.boss.AI.angles[0] = controller.foe_pos()
				controller.set_orb_laser_mode(controller.BURN)
				controller.deactivate_orb_lasers()
				controller.randomize_polarity(),
		
			controller.PROCESS: func():
				var start_pos = controller.boss.AI.angles[0] + 100*(controller.boss.global_position - controller.boss.AI.angles[0]).normalized().rotated(controller.pattern_polarity*PI/6)
				var end_pos = controller.boss.AI.angles[0] + 100*(controller.boss.global_position - controller.boss.AI.angles[0]).normalized().rotated(-controller.pattern_polarity*PI/6)
				var start_angle = (controller.boss.global_position - controller.boss.AI.angles[0]).normalized().rotated(-controller.pattern_polarity*PI/6 + PI)
				
				if controller.pattern_timer < 0.35:
					controller.active_orbs[0].target_pos = start_pos
					
				elif controller.pattern_timer < 0.75:
					if not controller.active_orbs[0].sustained_laser_audio_player.playing:
						controller.active_orbs[0].play_sustained_laser_audio()
					controller.active_orbs[0].target_pos = start_pos
					controller.active_orbs[0].telegraph_laser()
					controller.active_orbs[0].laser_endpoint_sprite.visible = true
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 150*start_angle)
					
				elif controller.pattern_timer < 1.5:
					controller.active_orbs[0].target_pos = Vector2(start_pos.x + (2*controller.pattern_timer - 1.5)*(end_pos.x - start_pos.x), start_pos.y + (2*controller.pattern_timer - 1.5)*(end_pos.y - start_pos.y))
					controller.active_orbs[0].activate_laser()
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 150*start_angle.rotated(controller.pattern_polarity*(2*controller.pattern_timer - 1.5)*PI/3))
				else:
					controller.active_orbs[0].deactivate_laser()
					controller.end_pattern(),
		}
		
		var sweep_process = Callable(controller.states[controller.State.BULLET_SWEEP][controller.PROCESS])
		controller.states[controller.State.BULLET_SWEEP][controller.PROCESS] = func():
			if controller.pattern_timer > 0.2 and controller.state_timer < 0.0:
				var num_shots = 15
				
				var dir = controller.pattern_direction.rotated(controller.pattern_polarity*(controller.state_counter - num_shots*0.5)*PI*0.7/num_shots)
				Violence.shoot_bullet(controller.active_orbs[0], controller.active_orbs[0].global_position, dir*220*(1.0 - 0.75*(1.0 - float(controller.state_counter)/num_shots)), 10)
				
			sweep_process.call()
		
		var spread_process = Callable(controller.states[controller.State.BULLET_SPREAD][controller.PROCESS])
		controller.states[controller.State.BULLET_SPREAD][controller.PROCESS] = func():
			if controller.pattern_timer > 0.2 and controller.state_timer < 0.0:
				var dir = controller.pattern_direction.rotated(PI*0.125)
				Violence.shoot_bullet(controller.active_orbs[0], controller.active_orbs[0].global_position, dir*125, 10)
				dir = controller.pattern_direction.rotated(PI*-0.125)
				Violence.shoot_bullet(controller.active_orbs[0], controller.active_orbs[0].global_position, dir*125, 10)
			spread_process.call()
		
		var l_s_enter = Callable(controller.states[controller.State.LASER_SNIPE][controller.ENTER])
		controller.states[controller.State.LASER_SNIPE][controller.ENTER] = func():
			l_s_enter.call()
			controller.pattern_timer += 0.25
	
	if controller.boss.AI.em2: # double orb attacks
		
		controller.states[controller.boss.AI.EM2_State.CROSS_SNIPE] = { 
			controller.ENTER: func():
				if not controller.orbs_in_formation:
					controller.formation_anchor_mode = controller.FOE_POS
					if randf() > 0.5:
						controller.randomize_polarity()
						controller.target_offsets = [100*Vector2(0, -1), 100*Vector2(controller.pattern_polarity, 0)]
					else:
						controller.target_offsets = [100*Vector2(0.5*sqrt(2), -0.5*sqrt(2)), 100*Vector2(-0.5*sqrt(2), -0.5*sqrt(2))]
					controller.transition_to_formation_and_resume()
					return
					
				controller.active_orbs[0].telegraph_laser2()
				controller.active_orbs[1].telegraph_laser2()
				controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
				controller.active_orbs[1].set_laser_endpoint(controller.active_orbs[1].global_position + 500*controller.active_orbs[1].global_position.direction_to(controller.foe_pos())),
			
			controller.PROCESS: func():
				if controller.pattern_timer > 0.33:
					controller.active_orbs[0].shoot_laser_pulse(controller.active_orbs[0].laser_dir)
					controller.active_orbs[1].shoot_laser_pulse(controller.active_orbs[1].laser_dir)
					controller.end_pattern(),
					
			controller.EXIT: func():
				controller.deactivate_orb_lasers()
		}
		
		controller.states[controller.boss.AI.EM2_State.DUAL_BULLET_SPIRAL] = { 
			controller.ENTER: func():
				controller.state_timer = 1.0
				controller.active_orbs[0].target_pos = controller.boss.global_position + Vector2(250, 0)
				controller.active_orbs[1].target_pos = controller.boss.global_position + Vector2(-250, 0),
		
			controller.PROCESS: func():
				if controller.pattern_timer < 1.0:
					controller.boss.AI.angles[0] = PI*2*randf()
				elif controller.pattern_timer < 4.25:
					controller.state_timer -= controller.delta * (GameManager.time_manager.enemy_timescale - 1) 
					if controller.state_timer < 0.0:
						controller.state_timer = 0.1
						for i in range(6):
							Violence.shoot_bullet(controller.active_orbs[0], controller.active_orbs[0].global_position, 333*Vector2(sin(controller.pattern_timer + i*PI/3 + controller.boss.AI.angles[0]), cos(controller.pattern_timer + i*PI/3 + controller.boss.AI.angles[0])))
							Violence.shoot_bullet(controller.active_orbs[1], controller.active_orbs[1].global_position, 333*Vector2(sin(controller.pattern_timer + i*PI/3 + controller.boss.AI.angles[0]), -cos(controller.pattern_timer + i*PI/3 + controller.boss.AI.angles[0])))
				if controller.pattern_timer > 1.0 + PI:
					controller.end_pattern()
		}
		
		var d_l_s_process = Callable(controller.states[controller.State.DOUBLE_LASER_SWING][controller.PROCESS])
		controller.states[controller.State.DOUBLE_LASER_SWING][controller.PROCESS] = func():
			d_l_s_process.call()
			controller.pattern_timer += controller.delta * 0.65
		
		var l_w_enter = Callable(controller.states[controller.State.LASER_WALL][controller.ENTER])
		controller.states[controller.State.LASER_WALL][controller.ENTER] = func():
			l_w_enter.call()
			controller.pattern_timer += 0.2
	
	if controller.boss.AI.em2: # triple orb attacks
		
		controller.states[controller.boss.AI.EM2_State.ATROPOS] = { 
			controller.ENTER: func():
				if not controller.orbs_in_formation:
					controller.formation_anchor_mode = controller.FOE_POS
					var base_angle = randf() * 2 * PI
					controller.target_offsets = [150*Vector2(sin(base_angle), cos(base_angle)), 100*Vector2(sin(base_angle + PI/2), cos(base_angle + PI/2)), 100*Vector2(sin(base_angle - PI/2), cos(base_angle - PI/2))]
					controller.transition_to_formation_and_resume()
					return
					
				controller.active_orbs[0].telegraph_laser2()
				controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
				controller.pattern_timer = -0.25,
				
			controller.PROCESS: func():
				controller.state_timer -= controller.delta * (GameManager.time_manager.enemy_timescale - 1) 
				controller.active_orbs[0].target_pos = controller.anchor_pos + controller.target_offsets[0]
				controller.active_orbs[1].target_pos = controller.anchor_pos + controller.target_offsets[1]
				controller.active_orbs[2].target_pos = controller.anchor_pos + controller.target_offsets[2]
				if controller.pattern_timer < 0.2:
					controller.anchor_pos = controller.foe_pos()
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
				elif controller.pattern_timer < 0.33:
					controller.formation_anchor_mode = controller.FREE_POINT
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
				elif controller.pattern_timer < 0.8:
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
					if controller.state_timer < 0:
						controller.state_timer = 0.1
						var x = 12
						var dir1 = controller.active_orbs[1].global_position.direction_to(controller.anchor_pos)
						var dir2 = controller.active_orbs[2].global_position.direction_to(controller.anchor_pos)
						Violence.shoot_bullet(controller.active_orbs[1], controller.active_orbs[1].global_position, dir1.rotated(PI/x)*333, 5)
						Violence.shoot_bullet(controller.active_orbs[1], controller.active_orbs[1].global_position, dir1.rotated(-PI/x)*333, 5)
						Violence.shoot_bullet(controller.active_orbs[2], controller.active_orbs[2].global_position, dir2.rotated(PI/x)*333, 5)
						Violence.shoot_bullet(controller.active_orbs[2], controller.active_orbs[2].global_position, dir2.rotated(-PI/x)*333, 5)
					controller.state_counter += 1
				if controller.pattern_timer > 1.25: 
					controller.active_orbs[0].shoot_laser_pulse(controller.active_orbs[0].laser_dir)
					controller.end_pattern(),
				
				controller.EXIT: func():
					controller.deactivate_orb_lasers()
		}
		
		# this code sucks lmao 2024 me is insane for this
		controller.states[controller.boss.AI.EM2_State.MULTI_SNIPE] = { 
			controller.ENTER: func():
				controller.formation_anchor_mode = controller.FOE_POS
				controller.boss.AI.angles = [PI/3, 3*PI/3, 5*PI/3]
				controller.target_offsets = [0, 0, 0]
				for i in range(3):
					controller.target_offsets[i] = Vector2(100*sin(controller.boss.AI.angles[i]), 100*cos(controller.boss.AI.angles[i]))
				
				controller.set_orb_laser_mode(controller.ZAP)
				controller.pattern_timer = -1.0,
			
			controller.PROCESS: func():
				controller.pattern_timer += controller.delta * 0.33
				var pattern_timer = controller.pattern_timer
				if pattern_timer < -0.67:
					controller.move_orbs_to_target_offsets()
				elif pattern_timer < -0.33:
					controller.boss.AI.angles[0] = controller.target_offsets[0].rotated(2*PI*randf())
				elif pattern_timer < 0.0:
					controller.boss.AI.angles[1] = controller.target_offsets[1].rotated(2*PI*randf())
					controller.active_orbs[0].target_pos = controller.anchor_pos + controller.boss.AI.angles[0]
				elif pattern_timer < 0.33:
					controller.boss.AI.shoot_laser[0] = true
					controller.active_orbs[0].telegraph_laser2()
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
					controller.active_orbs[1].target_pos = controller.anchor_pos + controller.boss.AI.angles[1]
					controller.boss.AI.angles[2] = controller.target_offsets[1].rotated(2*PI*randf())
				elif pattern_timer < 0.67:
					if pattern_timer > 0.6 and controller.boss.AI.shoot_laser[0]:
						controller.active_orbs[0].shoot_laser_pulse(controller.active_orbs[0].laser_dir)
						controller.active_orbs[0].deactivate_laser()
						controller.boss.AI.shoot_laser[0] = false
						controller.boss.AI.angles[0] = controller.target_offsets[0].rotated(2*PI*randf())
						controller.boss.AI.shoot_laser[1] = true
					controller.active_orbs[1].telegraph_laser2()
					controller.active_orbs[1].set_laser_endpoint(controller.active_orbs[1].global_position + 500*controller.active_orbs[1].global_position.direction_to(controller.foe_pos()))
					controller.active_orbs[2].target_pos = controller.anchor_pos + controller.boss.AI.angles[2]
				elif pattern_timer < 1.0:
					if pattern_timer > 0.93 and controller.boss.AI.shoot_laser[1]:
						controller.active_orbs[1].shoot_laser_pulse(controller.active_orbs[1].laser_dir)
						controller.active_orbs[1].deactivate_laser()
						controller.boss.AI.shoot_laser[1] = false
						controller.boss.AI.angles[1] = controller.target_offsets[1].rotated(2*PI*randf())
						controller.boss.AI.shoot_laser[2] = true
					controller.active_orbs[2].telegraph_laser2()
					controller.active_orbs[2].set_laser_endpoint(controller.active_orbs[2].global_position + 500*controller.active_orbs[2].global_position.direction_to(controller.foe_pos()))
					controller.active_orbs[0].target_pos = controller.anchor_pos + controller.boss.AI.angles[0]
				elif pattern_timer < 1.33:
					if pattern_timer > 1.27 and controller.boss.AI.shoot_laser[2]:
						controller.active_orbs[2].shoot_laser_pulse(controller.active_orbs[2].laser_dir)
						controller.active_orbs[2].deactivate_laser()
						controller.boss.AI.shoot_laser[2] = false
						controller.boss.AI.angles[2] = controller.target_offsets[2].rotated(2*PI*randf())
						controller.boss.AI.shoot_laser[0] = true
					controller.active_orbs[0].telegraph_laser2()
					controller.active_orbs[0].set_laser_endpoint(controller.active_orbs[0].global_position + 500*controller.active_orbs[0].global_position.direction_to(controller.foe_pos()))
					controller.active_orbs[1].target_pos = controller.anchor_pos + controller.boss.AI.angles[1]
				elif pattern_timer < 1.67:
					if pattern_timer > 1.6 and controller.boss.AI.shoot_laser[0]:
						controller.active_orbs[0].shoot_laser_pulse(controller.active_orbs[0].laser_dir)
						controller.active_orbs[0].deactivate_laser()
						controller.boss.AI.shoot_laser[0] = false
						controller.boss.AI.shoot_laser[1] = true
					controller.active_orbs[1].telegraph_laser2()
					controller.active_orbs[1].set_laser_endpoint(controller.active_orbs[1].global_position + 500*controller.active_orbs[1].global_position.direction_to(controller.foe_pos()))
					controller.active_orbs[2].target_pos = controller.anchor_pos + controller.boss.AI.angles[2]
				elif pattern_timer < 2.0:
					if pattern_timer > 1.93 and controller.boss.AI.shoot_laser[1]:
						controller.active_orbs[1].shoot_laser_pulse(controller.active_orbs[1].laser_dir)
						controller.active_orbs[1].deactivate_laser()
						controller.boss.AI.shoot_laser[1] = false
					controller.active_orbs[2].telegraph_laser2()
					controller.active_orbs[2].set_laser_endpoint(controller.active_orbs[2].global_position + 500*controller.active_orbs[2].global_position.direction_to(controller.foe_pos()))
				elif pattern_timer > 2.27:
					controller.active_orbs[2].shoot_laser_pulse(controller.active_orbs[2].laser_dir)
					controller.active_orbs[2].deactivate_laser()
					controller.end_pattern(),
					
			controller.EXIT: func():
				controller.deactivate_orb_lasers()
		}
		
		var l_c_process = Callable(controller.states[controller.State.LASER_CAGE][controller.PROCESS])
		controller.states[controller.State.LASER_CAGE][controller.PROCESS] = func():
			controller.pattern_rot += 0.5*controller.pattern_rot_vel*controller.delta*GameManager.time_manager.enemy_timescale
			if controller.state_counter == 1:
				var t = sin(controller.pattern_timer*PI/2.5)
				controller.pattern_speed = 75*sqrt(t) if t > 0 else 0
				controller.anchor_pos += 0.5*controller.pattern_direction*controller.pattern_speed*controller.delta*GameManager.time_manager.enemy_timescale
				controller.pattern_timer += controller.delta
			l_c_process.call()
		
		var l_d_process = Callable(controller.states[controller.State.LASER_DISC][controller.PROCESS])
		controller.states[controller.State.LASER_DISC][controller.PROCESS] = func():
			controller.pattern_timer += controller.delta*0.35
			controller.delta += controller.delta*0.35
			l_d_process.call()
			if controller.state_counter == 1:
				var homing_speed = 200
				controller.anchor_pos += controller.delta*200*(controller.anchor_pos.direction_to(controller.foe_pos()))
	
	if controller.boss.AI.em2: # halve attack cooldown
		var o_process = Callable(controller.states[controller.State.ORBIT][controller.PROCESS])
		controller.states[controller.State.ORBIT][controller.PROCESS] = func():
			controller.pattern_timer += controller.delta
			o_process.call()

# makes attacks scale properly with perceptual downsampling, solidarity, faith etc.
func update(chain: ModLoaderHookChain, delta):
	
	var controller := chain.reference_object as CityBossOrbController
	
	chain.execute_next([delta])
	
	controller.pattern_timer += delta * (GameManager.time_manager.enemy_timescale - 1)

func get_random_pattern(chain: ModLoaderHookChain, orb_count = -1):
	
	var controller := chain.reference_object as CityBossOrbController
	
	if controller.boss.AI.em2:
		
		if orb_count < 1:
			var max_orbs = controller.available_orbs()
			if max_orbs < 2:
				orb_count = 1
			else:
				var possible_counts = range(1, max_orbs + 1)
				possible_counts.erase(controller.last_pattern_orb_count)
				var weights = [1.0, 0.8, 10.5].slice(0, possible_counts.size())
				orb_count = Util.choose_weighted(possible_counts, weights)
		
		controller.last_pattern_orb_count = orb_count
		if orb_count == 1 and controller.enemy_deployment_needed():
			return controller.State.PICK_UP_ENEMY
		
		return [controller.boss.AI.ADV_1, controller.boss.AI.ADV_2, controller.boss.AI.ADV_3][orb_count - 1].pick_random()
		
	else:
		return chain.execute_next([orb_count])

func pattern_can_combo(chain: ModLoaderHookChain, pattern):
	
	var controller := chain.reference_object as CityBossOrbController
	
	if controller.boss.AI.em2:
		return not pattern in [controller.State.LASER_DISC, controller.State.DEPLOY_ENEMY, controller.boss.AI.EM2_State.MULTI_SNIPE, controller.boss.AI.EM2_State.DUAL_BULLET_SPIRAL]
	else:
		return chain.execute_next([pattern])

func orbs_needed_for_pattern(chain: ModLoaderHookChain, pattern):
	
	var controller := chain.reference_object as CityBossOrbController
	
	if controller.boss.AI.em2:
		if pattern == controller.State.PICK_UP_ENEMY: return 1
		if pattern in controller.boss.AI.ADV_1: return 1
		if pattern in controller.boss.AI.ADV_2: return 2
		return 3
	else:
		return chain.execute_next([pattern])

