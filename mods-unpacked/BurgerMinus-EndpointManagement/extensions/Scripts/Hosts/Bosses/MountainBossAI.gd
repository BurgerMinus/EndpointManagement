extends "res://Scripts/Hosts/Bosses/MountainBossAI.gd"

var em1 = false
var second_laser = false

const EM1_SUMMON_PATTERNS = [
	{
		'enemies': [Enemy.EnemyType.SHOTGUN, Enemy.EnemyType.SHOTGUN],
		'offsets': [Vector2(0.5, 0), Vector2(0, 0.5)],
		'weight': 1
	},
	{
		'enemies': [Enemy.EnemyType.WHEEL, Enemy.EnemyType.WHEEL, Enemy.EnemyType.WHEEL],
		'offsets': [Vector2(1.0, 0)*0.5, Vector2(0.5, -0.866)*0.5, Vector2(-0.5, -0.866)*0.5],
		'weight': 1
	},
	{
		'enemies': [Enemy.EnemyType.CHAIN, Enemy.EnemyType.FLAME],
		'offsets': [Vector2(0.4, 0.4), Vector2(-0.4, 0.4)],
		'weight': 1
	}
]

enum EM1_State{ # randomish numbers to avoid collision with State
	DIRECT_WAVE = 4370,
	TELEGRAPH_COLOSSAL_WAVE = 4371,
	COLOSSAL_WAVE = 4372
}

func initialize(body_, starting_conditions = null):
	super(body_, starting_conditions)
	
	em1 = Upgrades.get_antiupgrade_value('harder_bosses') >= 1
	
	var t_s_enter = Callable(states[State.TELEGRAPH_SUMMON][ENTER])
	states[State.TELEGRAPH_SUMMON][ENTER] = func():
		body.mass = 50
		t_s_enter.call()
	
	var t_s_exit
	if states[State.TELEGRAPH_SUMMON].has(EXIT):
		t_s_exit = Callable(states[State.TELEGRAPH_SUMMON][EXIT])
	else:
		t_s_exit = func():
			pass
	states[State.TELEGRAPH_SUMMON][EXIT] = func():
		body.mass = 5
		t_s_exit.call()
	
	var s_enter = Callable(states[State.SUMMON][ENTER])
	states[State.SUMMON][ENTER] = func():
		body.immobile = true
		s_enter.call()
	
	var s_exit = Callable(states[State.SUMMON][EXIT])
	states[State.SUMMON][EXIT] = func():
		body.immobile = false
		s_exit.call()
	
	if em1:
		
		super_move_thresholds = [0.8, 0.6, 0.4, 0.2, 0]
		
		var a_enter = Callable(states[State.APPROACH][ENTER])
		states[State.APPROACH][ENTER] = func():
			if randf() > 0.5:
				set_state(EM1_State.TELEGRAPH_COLOSSAL_WAVE)
			else:
				a_enter.call()
		
		var d_process = Callable(states[State.DISCOMBOBULATE][PROCESS])
		states[State.DISCOMBOBULATE][PROCESS] = func():
			for event in frame_events:
				if event[0] == EnemyEvent.DAMAGED: event[0] = null
			d_process.call()
		
		var d_l_enter = Callable(states[State.DIAGONAL_LASER][ENTER])
		states[State.DIAGONAL_LASER][ENTER] = func():
			d_l_enter.call()
			state_timer *= 0.66
		
		var d_l_process = Callable(states[State.DIAGONAL_LASER][PROCESS])
		states[State.DIAGONAL_LASER][PROCESS] = func():
			if state_timer < 0.0:
				if not second_laser: #|#
					second_laser = true
					set_state(State.TELEGRAPH_LASER)
				else:
					second_laser = false
			d_l_process.call()
		
		var d_l_exit = Callable(states[State.DIAGONAL_LASER][EXIT])
		states[State.DIAGONAL_LASER][EXIT] = func():
			body.laser_audio.stop() # might be completely unnecessary lol
			d_l_exit.call()
		
		states[EM1_State.DIRECT_WAVE] = {
			ENTER: func(): 
				stop_moving()
				body.accel = 8
				var wave_dir = Vector2(to_foe.x, to_foe.y).normalized()
				aim_point = body.foot_position + 400*wave_dir
				body.animplayer.speed_scale = min(1.0, 0.8 + (dist_to_foe*0.002) + 0.1*phase)
				if wave_dir.x > 0:
					body.play_animation("AttackRight")
				elif body.aim_direction.x < 0:
					body.play_animation("AttackLeft")
				else:
					body.play_animation("Attack"),
				
			PROCESS: func():
				if event_happened(EnemyEvent.ANIMATION_TRIGGER):
					body.spawn_explosion_wave(limit_wave_endpoint_to_terrain_bounds(aim_point))
				
				if event_happened(EnemyEvent.ANIMATION_FINISHED):
					exit_behaviour(),
					
			EXIT: func():
				body.animplayer.speed_scale = 1.0
		}
		
		states[EM1_State.TELEGRAPH_COLOSSAL_WAVE] = {
			ENTER: func():
				body.mass = 50
				if not point_reachable(arena_center):
					exit_behaviour(ABORTED)
					return
					
				navigation.set_navigation_target(arena_center)
				body.play_animation('Walk')
				state_timer = 5.0,
			
			PROCESS: func():
				follow_nav_path()
				if navigation.at_destination():
					set_state(EM1_State.COLOSSAL_WAVE)
				elif state_timer < 0:
					exit_behaviour(ABORTED),
			
			EXIT: func():
				body.mass = 5
		}
		
		states[EM1_State.COLOSSAL_WAVE] = {
			ENTER: func():
				body.immobile = true
				state_counter = 3
				state_timer = 0.5
				stop_moving()
				body.accel = 10.0
				body.play_animation('Special'),
				
			PROCESS: func():
				var t = min(0.5 - state_timer, 0.5)
				body.sprite.position.y = -(t - 2*t*t) * (40*8)
				
				if event_happened(EnemyEvent.ANIMATION_TRIGGER):
					spawn_colossal_wave(state_counter)
						
				if event_happened(EnemyEvent.ANIMATION_FINISHED):
					if state_counter > 1:
						state_counter -= 1
						state_timer = 0.5
						body.play_animation('Special', true)
					else:
						exit_behaviour(),
						
			EXIT: func():
				body.immobile = false
				body.sprite.position.y = 0
		}	

func get_weighted_behaviour_options():
	var behaviours = super()
	if em1 and phase > 0:
		behaviours.append([EM1_State.DIRECT_WAVE, 0.75])
	return behaviours

func choose_random_pillar_pattern():
	super()
	if em1:
		cur_pillar_pattern = Util.choose_random(EM1_SUMMON_PATTERNS)

func spawn_next_pillar():
	super()
	if em1:
		var i = len(cur_pillar_pattern['enemies']) - state_counter
		var point = arena_center - cur_pillar_pattern['offsets'][i]*arena_radius
		var delay = body.spawn_explosion_wave(limit_wave_endpoint_to_terrain_bounds(point), 5)
		body.spawn_pillar_after_delay(cur_pillar_pattern['enemies'][i], point, delay)

func spawn_colossal_wave(state_counter = 0):
	var squish_factor = 7.5
	var aim_angles
	if state_counter % 2 == 0:
		aim_angles = [30 - squish_factor, 90, 150 + squish_factor, 210 - squish_factor, 270, 330 + squish_factor]
	else:
		aim_angles = [0, 60 - squish_factor, 120 + squish_factor, 180, 240 - squish_factor, 300 + squish_factor]
	
	var aim_points = []
	for angle in aim_angles:
		var angle_rad = deg_to_rad(angle)
		aim_points.append(body.foot_position + 400*Vector2(cos(angle_rad), sin(angle_rad)))
	
	for point in aim_points:
		spawn_explosion_wave(limit_wave_endpoint_to_terrain_bounds(point), 5, 0.07, 0.25, 0)
		spawn_explosion_wave(limit_wave_endpoint_to_terrain_bounds(point), 35, 0.07, 1, 0.5)

func spawn_explosion_wave(endpoint, damage = 15, delta_delay = 0.07, size = 0.5, mean_delay = 0): # copy of CPU_BOSS.spawn_explosion_wave with extra parameters
	var dir = body.foot_position.direction_to(endpoint)
	var start = body.foot_position + dir*30
	var disp = endpoint - start
	var dist = disp.length()
	
	if em1:
		delta_delay *= 0.5
	delta_delay /= GameManager.dm_game_speed_mod
	
	var angle = dir.angle()
	var num_explosions = int(dist/25)
	var delta_x = dist/max(num_explosions - 1, 1)
	var max_y = 30.0
	
	var point = Vector2.ZERO
	var delay = 0
	var points = []
	
	for i in range(num_explosions):
		points.append(point)
		point.x += delta_x
		
		if i == num_explosions - 3:
			point.y = (randf() - 0.5)*0.3*max_y
		elif i == num_explosions - 2:
			point = endpoint
		else:
			point.y += (2*randf() - 1 - point.y/max_y)*0.5*max_y
	
	for p in points:
		p = start + p.rotated(angle)
		var explosion_attack = Attack.new(self, damage, 500)
		Violence.spawn_explosion(p, explosion_attack, size + randf()*0.25, delay + randf()*0.03 + mean_delay)
		delay += delta_delay
		
	GameManager.camera.set_trauma(0.7 if is_in_group('player') else 0.4)
	return delay
