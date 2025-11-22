extends Object

func toggle_enhancement(chain: ModLoaderHookChain, is_player):
	
	var enemy = chain.reference_object as Enemy
	
	chain.execute_next([is_player])
	
	if not enemy is CPU_BOSS and not enemy is CityBossOrb:
		enemy.stun_resist = 0
	

func handle_skin(chain: ModLoaderHookChain):
	
	var enemy = chain.reference_object as Enemy
	
	chain.execute_next()
	
	if enemy.enemy_golem != null and enemy.enemy_type == enemy.enemy_golem.obsession_host_type:
		
		match enemy.enemy_type: # my programming professor would be so disappointed in me rn
			
			Enemy.EnemyType.SHOTGUN:
				enemy.sprite.texture = Util.get_cached_texture("res://Art/Characters/ShotgunnerRAM/Skin_RGB_63x113.png")
			Enemy.EnemyType.CHAIN:
				enemy.sprite.texture = Util.get_cached_texture("res://Art/Characters/ChainbotRAM/skin_gladiator_107x109.png")
			Enemy.EnemyType.FLAME:
				enemy.sprite.texture = Util.get_cached_texture(enemy.explosive_skin_path)
			Enemy.EnemyType.WHEEL:
				enemy.sprite.texture = Util.get_cached_texture(enemy.bulk_delivery_skin_path)
			Enemy.EnemyType.SHIELD:
				enemy.sprite.texture = Util.get_cached_texture(enemy.purple_skin_path)
			Enemy.EnemyType.SABER:
				enemy.sprite.texture = Util.get_cached_texture(enemy.purple_skin_path)
			Enemy.EnemyType.ARCHER:
				enemy.sprite.texture = Util.get_cached_texture(enemy.turret_skin_path)
				enemy.bow_sprite.texture = Util.get_cached_texture(enemy.turret_bow)
			Enemy.EnemyType.BAT:
				enemy.sprite.texture = Util.get_cached_texture(enemy.white_skin_path)
				enemy.paddle_sprite.texture = Util.get_cached_texture(enemy.white_bat)

func _physics_process(chain: ModLoaderHookChain, delta):
	
	var enemy = chain.reference_object as Enemy
	
	var golem_boss = enemy.prev_enemy_golem
	if enemy.was_recently_enemy_golem() and golem_boss.golem_upgrades["euphoria"] and golem_boss.euphoria_active:
		delta *= golem_boss.euphoria_multiplier
	
	chain.execute_next([delta])

func take_damage(chain: ModLoaderHookChain, attack):
	
	var enemy = chain.reference_object as Enemy
	
	var golem_boss = enemy.enemy_golem
	
	if enemy.swap_shield_health <= 0 and golem_boss != null and golem_boss.golem_upgrades["deviance"]:
		attack.damage *= 2
	
	chain.execute_next([attack])

func move(chain: ModLoaderHookChain, delta):
	
	var enemy = chain.reference_object as Enemy
	
	var golem_boss = enemy.prev_enemy_golem
	if enemy.was_recently_enemy_golem() and golem_boss.golem_upgrades["euphoria"] and golem_boss.euphoria_active:
		
		var cur_speed = enemy.effect_system.apply_speed_effects(enemy.max_speed)
		var cur_accel = enemy.effect_system.apply_accel_effects(enemy.accel)
			
		enemy.velocity = enemy.velocity.lerp(enemy.target_velocity*cur_speed, cur_accel*delta)
		enemy.velocity += enemy.applied_velocity
		
		if enemy.on_stairs:
			enemy.handle_stair_movement(enemy.velocity)
		
		# move_and_slide() uses its own delta for some reason so the game speed modifier has to be hacked in like this
		var true_velocity = enemy.velocity
		
		if enemy.subject_to_enemy_timescale():
			enemy.velocity *= GameManager.time_manager.enemy_timescale
		
		enemy.velocity *= golem_boss.euphoria_multiplier
		enemy.move_and_slide()
		enemy.velocity /= golem_boss.euphoria_multiplier
		
		if enemy.subject_to_enemy_timescale():
			enemy.velocity /= GameManager.time_manager.enemy_timescale
			
		enemy.velocity -= enemy.applied_velocity
		
		var col_count = enemy.get_slide_collision_count()
		if col_count > 0:
			var cols = []
			for i in range(col_count):
				cols.append(enemy.get_slide_collision(i))
			enemy.on_body_collision(cols, true_velocity)
		
	else:
		chain.execute_next([delta])
