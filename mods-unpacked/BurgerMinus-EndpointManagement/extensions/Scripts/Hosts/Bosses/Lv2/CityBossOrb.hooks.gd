extends Object

# resistances
func _ready(chain: ModLoaderHookChain):
	
	var orb := chain.reference_object as CityBossOrb
	
	chain.execute_next()
	
	orb.ignore_tar = true
	orb.stun_resist = 999
	if orb.AI.em2:
		orb.max_health = 40000
		orb.init_healthbar()
		orb.laser_damage = 65

# burn damage increase
func _physics_process(chain: ModLoaderHookChain, delta):
	
	var orb := chain.reference_object as CityBossOrb
	var burn_damage_mult = 1 if orb.is_player else 2
	
	# am i doing all this just to double the burn laser damage? yes. yes i am.
	# im sure theres a better way to have called super._physics_process(), but i could not figure it out :(
	if orb.AI.em2:
		
		if orb.subject_to_enemy_timescale():
			delta *= GameManager.time_manager.enemy_timescale
	
		orb.time_since_swap += delta
		orb.doubt_swap_cooldown -= delta
		
		orb.effect_system.update(delta)
		orb.update_flash(delta)
		orb.update_healthbar()
		
		if not orb.is_player and orb.player_enhancements_active and orb.time_since_swap > orb.RECENTLY_PLAYER_WINDOW:
			orb.toggle_enhancement(false)
		
		if orb.spawn_state == orb.SpawnState.SPAWNED:
			if orb.is_player:
				orb.player_process(delta)
			else:
				orb.ai_process(delta)
				
		if not orb.dead and not orb.stunned:
			orb.misc_update(delta)
		
		orb.attack_cooldown -= delta
		orb.special_cooldown -= delta
		orb.invincibility_timer -= delta
		
		orb.effect_system.apply_DoT(orb, delta)
		
		if orb.stunned:
			orb.stun_timer -= delta
			orb.update_stun_effect(delta)
			if orb.stun_timer < 0:
				orb.stunned = false
				orb.animplayer.play()
				
		elif orb.spawn_state == orb.SpawnState.SPAWNED:
			orb.animate()
		
		if not orb.immobile:
			orb.move(delta)
		else:
			orb.velocity = Vector2.ZERO
		
		orb.update_shield_sprite()
		orb.update_formation_change_audio()
		
		orb.laser_telegraph.modulate = Color.WHITE if int(GameManager.game_time*20)%2 else Color.RED
		orb.laser_endpoint_sprite.scale = Vector2.ONE*(0.5 + randf()*0.5)*0.75
		if orb.laser_active and orb.laser_mode == orb.BURN:
			var laser_attack = Attack.new(orb, burn_damage_mult*120*delta, 20*orb.laser_dir)
			Violence.melee_attack(orb.laser_collider, laser_attack)
			
		if is_instance_valid(orb.held_entity):
			if orb.held_entity_dropped:
				orb.while_dropping_entity(delta)
			else:
				orb.while_holding_entity(delta)
		
		# shield regen 
		if orb.swap_shield_health <= 0:
			orb.healthbar.visible = false
			orb.AI.shield_timer -= delta
			if not orb.is_player and orb.AI.shield_timer <= 0.0 and orb.tethered:
				orb.add_swap_shield(500)
				orb.take_damage(Attack.new(orb.boss, 400))
				orb.AI.shield_timer = 2.0
				orb.healthbar.visible = true
				orb.swap_available.visible = false
	
	else:
		chain.execute_next([delta])

# reset stun resist
func break_tether(chain: ModLoaderHookChain):
	
	var orb := chain.reference_object as CityBossOrb
	
	chain.execute_next()
	
	orb.stun_resist = 1.0
	orb.effect_system.effect_immunities = [orb.EffectType.ACCEL_MULT, orb.EffectType.SPEED_MULT, orb.EffectType.SPEED_OVERRIDE]
	orb.effect_system.cancel_all_effects()

# reset stun resist temporarily
func on_shield_broken(chain: ModLoaderHookChain):
	
	var orb := chain.reference_object as CityBossOrb
	
	orb.stun_resist = 0.0
	
	# prevents you from farming the regenerating shield for easy full refills
	if orb.AI.first_shield_break: 
		orb.AI.first_shield_break = false
		chain.execute_next()
	else:
		orb.stun(2.0)
		orb.apply_effect(orb.EffectType.ACCEL_OVERRIDE, orb, 10, 0.5)
		GameManager.player.swap_manager.add_local_juice(0.2)
		if is_instance_valid(orb.held_entity):
			orb.start_dropping_entity()
		orb.enemy_fx.visible = true
		orb.swap_available.visible = true
		orb.shield_broken.emit()

	
	orb.stun_resist = 999
	orb.healthbar.visible = false

# zap damage increase
func shoot_laser_pulse(chain: ModLoaderHookChain, dir):
	
	var orb := chain.reference_object as CityBossOrb
	
	if orb.AI.em2:
		var laser_attack = Attack.new(orb, orb.laser_damage, 800*dir)
		var laser_params = LaserParams.new(orb.global_position, dir, laser_attack)
		laser_params.width = 6
		Violence.shoot_laser(laser_params)
		orb.play_laser_pulse_audio()
	else:
		chain.execute_next([dir])

# invincibility when detached
func take_damage(chain: ModLoaderHookChain, attack):
		
	var orb := chain.reference_object as CityBossOrb
	
	if orb.AI.em2:
		if orb.swap_shield_health <= 0:
			attack.damage = 0
	
	chain.execute_next([attack])

