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
		delta *= 1.5
		if cpu.AI.phase > 0:
			delta *= 2.0
	
	chain.execute_next([delta]) # run vanilla method

# extend laser past arena edge
func point_laser_at_point(chain: ModLoaderHookChain, laser_endpoint):
	
	var cpu := chain.reference_object as CPU_BOSS
	
	var laser_origin = cpu.global_position + cpu.eye_offset
	var laser_disp = laser_endpoint - laser_origin
	var laser_dir = laser_disp.normalized()
	
	laser_endpoint = chain.execute_next([laser_endpoint]) # run vanilla method
	
	if cpu.AI.em1:
		
		laser_endpoint += 66*laser_dir 
		
		var laser_length = laser_origin.distance_to(laser_endpoint) * 1.5
		cpu.eye_laser.rotation = (laser_endpoint - laser_origin).angle()
		cpu.eye_laser.scale.x = laser_length
	
		cpu.eye_laser_origin_sprite.global_position = laser_origin
		cpu.eye_laser_endpoint_sprite.global_position = laser_endpoint
	
		return laser_endpoint
