extends Object

# increase health to 5000
func _ready(chain: ModLoaderHookChain):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	chain.execute_next()
	
	if cpu.AI.em1:
		cpu.max_health = 5000
		cpu.init_healthbar()

# increase ram acceleration and speed
func start_ram(chain: ModLoaderHookChain):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	chain.execute_next() # run vanilla method
	
	if cpu.AI.em1:
		cpu.accel += 1
		cpu.max_speed += 200

# remove damage vulnerability during ram
func take_damage(chain: ModLoaderHookChain, attack):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	if cpu.AI.em1:
		if cpu.ramming and not cpu.is_player:
			attack.damage /= 1.5
	
	chain.execute_next([attack]) # run vanilla method

# increase explosion wave speed
func spawn_explosion_wave(chain: ModLoaderHookChain, endpoint, damage = 15, delta_delay = 0.07):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	delta_delay /= GameManager.time_manager.enemy_timescale
	
	if cpu.AI.em1:
		delta_delay *= 0.5
	
	return chain.execute_next([endpoint, damage, delta_delay]) # run vanilla method

# increase laser sweep speed
func update_laser_sweep(chain: ModLoaderHookChain, delta):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	if cpu.AI.em1:
		var scale_factor = 1.5
		if cpu.AI.phase > 0:
			scale_factor *= 2.0
		delta *= scale_factor
		cpu.laser_timer = min(cpu.LASER_DURATION, cpu.laser_timer + delta)
		var t = cpu.laser_timer / cpu.LASER_DURATION
		
		var laser_angle = cpu.laser_start_angle*(1.0 - t) + cpu.laser_end_angle*t
		var laser_endpoint = cpu.laser_center + Vector2.RIGHT.rotated(laser_angle)*cpu.laser_radius
		cpu.laser_endpoint = cpu.point_laser_at_point(laser_endpoint)
		
		var laser_attack = Attack.new(self, 5 * (1.0 + scale_factor))
		laser_attack.impulse = Vector2.RIGHT.rotated(laser_angle)*100
		Violence.melee_attack(cpu.eye_laser_collider, laser_attack)
		
		cpu.laser_fire_spawn_timer -= delta
		if cpu.laser_fire_spawn_timer < 0:
			cpu.laser_fire_spawn_timer = cpu.LASER_FIRE_SPAWN_INTERVAL
			cpu.spawn_fire_at_point(laser_endpoint)
			
		cpu.eye_laser_endpoint_sprite.global_scale = Vector2.ONE*(0.5 + randf()*0.5)
		cpu.eye_laser_origin_sprite.global_scale = Vector2.ONE*(0.5 + randf()*0.5)
			
		if cpu.laser_timer >= cpu.LASER_DURATION:
			cpu.stop_laser_sweep()
	else:
		chain.execute_next([delta]) # run vanilla method

# extend laser past arena edge
func point_laser_at_point(chain: ModLoaderHookChain, laser_endpoint):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	var laser_origin = cpu.global_position + cpu.eye_offset
	var laser_disp = laser_endpoint - laser_origin
	var laser_dir = laser_disp.normalized()
	
	laser_endpoint = chain.execute_next([laser_endpoint]) # run vanilla method
	
	if cpu.AI.em1:
		
		laser_endpoint += 150*laser_dir 
		
		var laser_length = laser_origin.distance_to(laser_endpoint) * 1.5
		cpu.eye_laser.rotation = (laser_endpoint - laser_origin).angle()
		cpu.eye_laser.scale.x = laser_length
	
		cpu.eye_laser_origin_sprite.global_position = laser_origin
		cpu.eye_laser_endpoint_sprite.global_position = laser_endpoint
	
		return laser_endpoint
