extends "res://Scripts/Hosts/Bosses/Lv2/CityBossOrbAI.gd"

var em2 = false
var shield_timer = 2.0
var frame_delay = 10
var strafe_timer = 1.0
var first_shield_break = true

enum EM2_State{
	SHOCKWAVE = 7560
}

func initialize(b, starting_conditions = null):
	super(b, starting_conditions)
	em2 = Upgrades.get_antiupgrade_value('harder_bosses') >= 2
	
	if em2:
		
		states[EM2_State.SHOCKWAVE] = { 
			ENTER: func():
				target_pos = global_position
				body.accel = 5
				frame_delay = 10
				state_counter = 5*frame_delay
				state_timer = 0.75,
				
			PROCESS: func():
				move_toward_point(target_pos)
				if state_timer < 0.0:
					stop_moving()
					if state_counter > 0:
						state_counter -= 1
						if state_counter % frame_delay == 0:
							for i in range(18):
								var angle = (i + 0.5*(state_counter % 2)) * (PI/9)
								Violence.shoot_bullet(body, body.global_position, 200*Vector2(sin(angle), cos(angle)), 10)
					else:
						end_attack()
		}
		attack_states.append(EM2_State.SHOCKWAVE)
		
		var follow_enter = Callable(states[State.FOLLOW][ENTER])
		states[State.FOLLOW][ENTER] = func():
			follow_enter.call()
			body.accel = 4.0
		
		var shotgun_process = Callable(states[State.SHOTGUN][PROCESS])
		states[State.SHOTGUN][PROCESS] = func():
			if state_timer < 0.0:
				if state_counter > 0:
					for i in range(5):
						Violence.shoot_bullet(body, body.global_position, 125*(1.0 + randf())*dir_to_foe.rotated((randf() - 0.5)*PI*0.25), 10)
						Violence.shoot_bullet(body, body.global_position, 125*(1.0 - randf()*0.5)*dir_to_foe.rotated((randf() - 0.5)*PI*0.25), 10)
			shotgun_process.call()
		
		var gtfo_enter = Callable(states[State.GTFO_BLAST][ENTER])
		states[State.GTFO_BLAST][ENTER] = func():
			gtfo_enter.call()
			body.max_speed = 150
		
		var gtfo_process = Callable(states[State.GTFO_BLAST][PROCESS])
		states[State.GTFO_BLAST][PROCESS] = func():
			if state_timer < 0.0:
				Violence.spawn_explosion(body.global_position, Attack.new(self, 50, 1000), 1.8)
			gtfo_process.call()
		
		var strafe_enter = Callable(states[State.STRAFE][ENTER])
		states[State.STRAFE][ENTER] = func():
			strafe_enter.call()
			strafe_timer = 0.6 + delta
		
		var strafe_process = Callable(states[State.STRAFE][PROCESS])
		states[State.STRAFE][PROCESS] = func():
			strafe_timer -= delta
			if strafe_timer < 0.0:
				strafe_timer = 0.2
				Violence.shoot_bullet(body, body.global_position, 125*aim_dir, 10)
			strafe_process.call()
		
		var l_c_enter = Callable(states[State.LASER_CHASE][ENTER])
		states[State.LASER_CHASE][ENTER] = func():
			l_c_enter.call()
			state_timer = 2.5
			body.max_speed = 200
		
		var l_c_process = Callable(states[State.LASER_CHASE][PROCESS])
		states[State.LASER_CHASE][PROCESS] = func():
			l_c_process.call()
			body.set_laser_endpoint(0.94*body.laser_endpoint + 0.06*foe_pos)
			state_timer -= delta*0.33
		
		var l_s_enter = Callable(states[State.LASER_SNIPE][ENTER])
		states[State.LASER_SNIPE][ENTER] = func():
			l_s_enter.call()
			state_timer = 1.0
		
		var l_s_process = Callable(states[State.LASER_SNIPE][PROCESS])
		states[State.LASER_SNIPE][PROCESS] = func():
			if state_timer > 0.25:
				aim_dir = 0.8*aim_dir + 0.2*dir_to_foe
			l_s_process.call()
		
		

func end_attack():
	super()
	if em2:
		attack_cooldown = 1.5 + 1.5 * (body.boss.health / body.boss.max_health)
