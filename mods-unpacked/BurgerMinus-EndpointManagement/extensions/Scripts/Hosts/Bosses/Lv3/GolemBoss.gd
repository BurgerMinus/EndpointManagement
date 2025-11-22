extends "res://Scripts/Hosts/Bosses/Lv3/GolemBoss.gd"

@onready var mania_bar = $SwapCursor/CanvasLayer2/JuiceSwapBar/ExtraJuice

var em3
var adv_boss_ai = false
var adv_host_ai = false
var give_golem_upgrades = false
var minor_regen = false

# debug use
var golem_upgrade_seed = -1
var infinite_energy = false
var local_energy_regen = false
var global_energy_regen = false

# variety 
var variety_mult = 1.0
var variety_list = []
var variety_decay_timer = 10.0

# doubt
var free_swap = false
var last_juice_spent = 0

# euphoria
var euphoria_active = false
var euphoria_timer = 0.0
var euphoria_multiplier = 2.0

# indulgence
var indulgence_chain_targets = []
var indulgence_chain_cooldown = 0.0
var indulgence_timer = 0.0

# other
var obsession_host_type = Enemy.EnemyType.UNKNOWN
var scorn_swap_line

enum EM3_State{
	
}

var golem_upgrades = {
	"caution": false,
	"compulsion": false,
	"deviance": false,
	"doubt": false,
	"efficiency": false,
	"euphoria": false,
	"habit": false,
	"haste": false,
	"hubris": false,
	"hyperopia": false,
	"indulgence": false,
	"mania": false,
	"obsession": false,
	"scorn": false,
	"thorn": false
}

func _ready():
	em3 = Upgrades.get_antiupgrade_value('harder_bosses') >= 3
	give_golem_upgrades = em3
	adv_host_ai = em3
	adv_boss_ai = em3
	minor_regen = em3
	super()

func init():
	super()
	
	scorn_swap_line = load(ModLoaderMod.get_unpacked_dir().path_join("BurgerMinus-EndpointManagement/ScornSwapLine.tscn"))
#	scorn_swap_line = ResourceLoader.load("res://Scenes/UI/SwapLine.tscn", "", ResourceLoader.CACHE_MODE_REPLACE)
	
	# layer mania bar under green bar
	juice_bar_green_overlay.z_index = mania_bar.z_index + 1

func define_states():
	
	super()
	
	var h_a_process = Callable(states[State.HOST_AUTOPILOT][PROCESS])
	states[State.HOST_AUTOPILOT][PROCESS] = func():
		
		h_a_process.call()
		
		if not adv_boss_ai:
			return
		
		host.AI.override_foe = GameManager.player.true_host
		if not chain_swap_mode and golem_upgrades["indulgence"] and indulgence_chain_cooldown < 0.0:
			indulgence_chain_cooldown = 15.0
			indulgence_chain_targets.clear()
			
			var init_swap_cost = 1.5 if host.dead else 1.0
			var chain_swap_cost = 0.33
			
			if indulgence_timer > 0 and not host.dead:
					init_swap_cost *= 0.33
			if golem_upgrades["hubris"]:
				if host.dead:
					init_swap_cost *= 2.0
				else:
					init_swap_cost *= 0.5
				chain_swap_cost *= 0.5
			if golem_upgrades["thorn"]:
				init_swap_cost *= 1.33
				chain_swap_cost *= 1.33
			
			if local_juice >= (init_swap_cost + 2*chain_swap_cost) and randf() > 0.5:
				set_indulgence_chain_targets()
	
	var s_d_process = Callable(states[State.SELF_DESTRUCT][PROCESS])
	states[State.SELF_DESTRUCT][PROCESS] = func():
		if not adv_boss_ai:
			s_d_process.call()
			return
		if state_timer < 0.0:
			var explosion = Attack.new(host, 300, 1000)
			explosion.hit_allies = true
			var explosion_position = host.global_position
			swap_immediately()
			Violence.spawn_explosion(explosion_position, explosion)
	
	var t_s_process = Callable(states[State.TELEGRAPH_SWAP][PROCESS])
	states[State.TELEGRAPH_SWAP][PROCESS] = func():
		
		if not adv_boss_ai:
			t_s_process.call()
			return
		
		if not is_instance_valid(swap_target) or swap_target.dead or swap_target is GolemSpider:
			swap_cooldown = 0.5
			set_state(State.HOST_AUTOPILOT)
			return
		
		elif swap_target.is_player and is_instance_valid(host): # it should be impossible for it to target the player without a valid host but idk
			
			var swap_1_cost = 1.5 if host.dead else 1.0
			var swap_2_cost = 1.0
			var touche_regen = 0.5
			
			if golem_upgrades["compulsion"]:
				touche_regen *= 0.5
			if golem_upgrades["hubris"]:
				if host.dead:
					swap_1_cost *= 2.0
				else:
					swap_1_cost *= 0.5
				swap_2_cost *= 0.5
			if golem_upgrades["indulgence"]:
				swap_2_cost *= 0.33
				if indulgence_timer > 0 and not host.dead:
					swap_1_cost *= 0.33
			if golem_upgrades["thorn"]:
				swap_1_cost *= 1.33
				swap_2_cost *= 1.33
		
			var predicted_juice_required = swap_1_cost + swap_2_cost - touche_regen
			
			var doubt_applicable = false
			if golem_upgrades["doubt"] and is_instance_valid(host):
				doubt_applicable = not host.dead and host.global_position.distance_to(swap_target.global_position) > 1.5
			
			if local_juice < predicted_juice_required and touche_regen < swap_2_cost and not doubt_applicable:
				swap_cooldown = 0.5
				set_state(State.HOST_AUTOPILOT)
				return
		
		swap_cursor.global_position = swap_target.global_position + Vector2.UP*20
		if swap_telegraph_timer < 0.0:
			swap_immediately()

func _process(delta):
	
	if adv_boss_ai:
		swap_telegraph_timer -= delta
	
	if minor_regen:
		local_juice = min(max_local_juice, local_juice + delta/30.0)
	if infinite_energy or local_energy_regen:
		local_juice = min(max_local_juice, local_juice + delta)
	if infinite_energy or global_energy_regen:
		global_juice = min(max_global_juice, global_juice + delta)
	
	if variety_mult > 1.0:
		variety_decay_timer -= delta
		if variety_decay_timer < 0.0:
			variety_decay_timer = 10.0
			GameManager.player.variety_bonus -= 0.2
	
	if golem_upgrades["euphoria"]:
		euphoria_timer -= delta
		if euphoria_timer < 0 and euphoria_active:
			euphoria_active = false
			host.set_anim_speed_scale(host.anim_speed_scale / euphoria_multiplier)
	
	if golem_upgrades["indulgence"]:
		indulgence_timer -= delta
		indulgence_chain_cooldown -= delta
	
	super(delta)

func apply_host_buffs():
	
	super()
	
	if adv_boss_ai and not host is GolemSpider:
		host.add_swap_shield(250)
	
	if adv_host_ai:
		
		match host.enemy_type:
			
			Enemy.EnemyType.SHOTGUN:
				host.max_attack_cooldown *= 0.85
			
			Enemy.EnemyType.CHAIN:
				host.grapple.retract_force *= 1.25
			
			Enemy.EnemyType.FLAME:
				host.base_flame_emission_rate *= 1.2
			
			Enemy.EnemyType.WHEEL:
				host.dash_charge_bonus += 0.25
			
			Enemy.EnemyType.SHIELD:
				host.min_bullet_orbit_speed += 1.0
			
			Enemy.EnemyType.SABER:
				host.dash_speed *= 1.5
			
			Enemy.EnemyType.ARCHER:
				host.speed_while_charging += 0.1*host.max_speed
			
			Enemy.EnemyType.BAT:
				host.paddle_kb_mult *= 1.25

func has_juice(amount):
	amount = convert_juice(amount)
	return super(amount)

func spend_juice(amount):
	amount = convert_juice(amount)
	if free_swap or infinite_energy:
		amount = 0
	if golem_upgrades["indulgence"]:
		if indulgence_timer > 0.0 and not host.dead:
			amount *= 0.33
		indulgence_timer = 1.0
	super(amount)
	last_juice_spent = amount
	free_swap = false

func restore_swap_juice_from_kill(equivalent_basic_kills):
	if golem_upgrades["compulsion"]:
		equivalent_basic_kills *= 0.5
	super(equivalent_basic_kills)

func handle_swap_visuals(old_host, new_host):
	if golem_upgrades["scorn"]:
		var swap_line = scorn_swap_line.instantiate()
		swap_line.speed_scale = 0.5
		swap_line.golem_boss = self
		swap_line.set_endpoints(old_host, new_host)
		GameManager.objects_node.add_child(swap_line)
	else:
		super(old_host, new_host)

func get_valid_swap_targets():
	var valid_candidates = super()
	if adv_boss_ai and randf() > 0.25:
		valid_candidates.append(GameManager.player.true_host)
	return valid_candidates

func swap_to(new_host, autopilot_after_swap = true):
	
	if not is_instance_valid(new_host): return
	
	if is_instance_valid(host):
		variety_list.push_front(host.enemy_type)
		if variety_list.size() > 4:
			variety_list.pop_back()
		set_variety_mult()
		variety_decay_timer = 10.0
	
	if golem_upgrades["doubt"] and last_juice_spent != 0 and new_host.time_since_enemy_golem_swap < 1.0:
		free_swap = true
		local_juice += 0.75*last_juice_spent
	
	if golem_upgrades["haste"]:
		var explosion_attack = Attack.new(new_host, 40, 1500)
		explosion_attack.deflect_type = Attack.DeflectType.REPULSE
		Violence.spawn_explosion(new_host.global_position, explosion_attack, 1.5)
	
	if golem_upgrades["euphoria"]:
		euphoria_active = true
		euphoria_timer = 2.0
		new_host.set_anim_speed_scale(new_host.anim_speed_scale * euphoria_multiplier)
	
	if golem_upgrades['caution']:
		var missing_health = new_host.max_health - new_host.health
		var time = missing_health/25.0
		new_host.apply_effect(EnemyEffectSystem.EffectType.DAMAGE_OVER_TIME, self, -25.0, time)
		new_host.apply_effect(EnemyEffectSystem.EffectType.DAMAGE_MULT, self, 1.5, time)
		new_host.apply_effect(EnemyEffectSystem.EffectType.SPEED_MULT, self, 0.75, time)
	
	super(new_host, autopilot_after_swap)

func consider_defensive_swap():
	var result = super()
	if golem_upgrades["hubris"] and current_state != State.TELEGRAPH_SWAP:
		if local_juice >= convert_juice(1.0) and host.swap_shield_health / host.max_swap_shield_health <= 0.5:
			swap_telegraph_timer = 4.0
			set_state(State.TELEGRAPH_SWAP)
			return true
		elif randf() < 1.0/delta and host.swap_shield_health / host.max_swap_shield_health <= 0.2:
			swap_telegraph_timer = 4.0
			set_state(State.TELEGRAPH_SWAP)
			return true
	return result

func set_chain_swap_mode(state):
	if state:
		indulgence_chain_targets.clear()
		indulgence_chain_cooldown = 8.0
	super(state)

func consider_offensive_swap():
	if not chain_swap_mode and golem_upgrades["indulgence"] and not indulgence_chain_targets.is_empty():
		do_next_indulgence_chain_step()
		return true
	return super()

func swap_from_host(old_host):
	
	super(old_host)
	
	if golem_upgrades["euphoria"] and euphoria_active:
		old_host.set_anim_speed_scale(old_host.anim_speed_scale / euphoria_multiplier)
	
	if golem_upgrades["efficiency"]:
		
		var self_damage_attack = Attack.new(host, max(200, old_host.max_health*0.2), 800)
		self_damage_attack.hit_allies = true
		self_damage_attack.ignore_damage_modifiers = true
		self_damage_attack.bonuses.append(Fitness.Bonus.VANILLA)
		self_damage_attack.inflict_on(old_host)
		
		var explosion_attack = Attack.new(host, 60, 800)
		explosion_attack.hit_allies = true
		explosion_attack.ignored.append(old_host)
		explosion_attack.deflect_type = Attack.DeflectType.REPULSE
		explosion_attack.bonuses.append(Fitness.Bonus.KAMIKAZE)
		Violence.spawn_explosion(old_host.global_position, explosion_attack)

func get_random_swap_target():
	var target = super()
	
	var valid_candidates = get_valid_swap_targets()
	
	if golem_upgrades["obsession"]:
		if target != null and not target.enemy_type == obsession_host_type:
			var obsession_candidates = []
			for c in valid_candidates:
				if c.enemy_type == obsession_host_type:
					obsession_candidates.append(c)
			if obsession_candidates.size() > 0:
				obsession_candidates.sort_custom(func(a, b): return a.health/a.max_health > b.health/b.max_health)
				target = obsession_candidates[0]
	
	if golem_upgrades["doubt"] and last_juice_spent != 0:
		if target != null and not target.time_since_enemy_golem_swap < 1.0:
			var doubt_candidates = []
			for c in valid_candidates:
				if c.time_since_enemy_golem_swap < 1.0:
					doubt_candidates.append(c)
			if doubt_candidates.size() > 0:
				doubt_candidates.sort_custom(func(a, b): return a.health/a.max_health > b.health/b.max_health)
				target = doubt_candidates[0] # prioritize doubt candidate over obsession candidate
	
	return target

func spawn_ad():
	if golem_upgrades["obsession"] and ad_type_queue.is_empty() and obsession_host_type != Enemy.EnemyType.UNKNOWN: # it should not be unknown if obsession is active but idk
		ad_type_queue = UpgradeManager.VALID_ENEMY_TYPES.duplicate() + [obsession_host_type, obsession_host_type, obsession_host_type, obsession_host_type]
		ad_type_queue.shuffle()
	super()

func generate_and_apply_upgrades():
	
	super()
	
	if give_golem_upgrades: 
		
		# select and set golem upgrade(s)
		var golem_upgrade_set = generate_golem_upgrade_set()
		for g in golem_upgrade_set:
			golem_upgrades[g] = true
			set_golem_upgrade(g, true)
		
		# reorder dictionary keys so golem popups come up first
		var upgrades_copy = upgrades.duplicate(true)
		upgrades.clear()
		for upgrade in golem_upgrade_set:
			if upgrade in golem_upgrades.keys():
				upgrades[upgrade] = 1
		for upgrade in upgrades_copy.keys():
			upgrades[upgrade] = upgrades_copy[upgrade]

func generate_golem_upgrade_set():
	var presets = [
		["mania", "hyperopia"],
		["euphoria", "hyperopia"],
		["deviance", "hyperopia"],
		["doubt", "caution"],
		["obsession", "caution"],
		["hubris", "caution"],
		["scorn", "indulgence"],
		["efficiency", "haste"]
	]
	var golem_upgrade_set = presets.pick_random() if golem_upgrade_seed == -1 else presets[golem_upgrade_seed % 8]
	if randf() < 0.1:
		golem_upgrade_set.append("habit")
	if randf() < 0.01:
		golem_upgrade_set.append("compulsion")
	if randf() < 0.001:
		golem_upgrade_set.append("thorn")
	return golem_upgrade_set

func set_golem_upgrade(g, active = true):
	if g in golem_upgrades.keys():
		golem_upgrades[g] = active
	match g:
		"all":
			for upgrade in golem_upgrades.keys():
				set_golem_upgrade(upgrade, active)
		"obsession":
			toggle_obsession(active)
		"mania":
			toggle_mania(active)
		"hyperopia":
			toggle_hyperopia(active)
		"infinite_energy":
			infinite_energy = active
		"local_regen":
			local_energy_regen = active
		"global_regen":
			global_energy_regen = active

func toggle_mania(active = true):
	max_global_juice = 4.0 if active else 10.0
	global_juice = max_global_juice
	max_local_juice = 3.0 if active else 2.0
	local_juice = max_local_juice
	juice_bar.show_third_bar = active
	juice_bar.extra_juice.set_max(1 if active else 0)
	juice_bar.num_swaps_in_extra_bar = 1 if active else 0
	juice_bar_green_overlay.scale.x = 1.5 if active else 1.0
	mania_bar.visible = active

func toggle_obsession(active = true):
	ad_type_queue.clear()
	var bot = randi() % 8
	if golem_upgrades["hyperopia"] and bot == host.enemy_type:
		bot = randi() % 7
		if bot == host.enemy_type:
			bot = 7
	var obsession_set = generate_obsession_set("Deadlift")#Enemy.ENEMY_NAME[bot])
	var upgrade_sets = generate_hyperopia_sets() if golem_upgrades["hyperopia"] else valid_upgrades
	upgrades.clear()
	if active:
		var flag = true
		for data in obsession_set:
			var upgrade = data[0] if data is Array else data
			var count = data[1] if data is Array else 1
			upgrades[upgrade] = count
			if flag:
				flag = false
				obsession_host_type = Upgrades.upgrades[upgrade]["type"]
	else:
		obsession_host_type = Enemy.EnemyType.UNKNOWN
		for host_type in upgrade_sets.keys():
			var data = upgrade_sets[host_type].pick_random()
			var upgrade = data[0] if data is Array else data
			var count = data[1] if data is Array else 1
			upgrades[upgrade] = count
	host.toggle_enhancement(false)

func toggle_hyperopia(active = true):
	if golem_upgrades["obsession"]:
		toggle_obsession() # reroll so it isnt the current host lmoa
		return
	upgrades.clear()
	var upgrade_sets = generate_hyperopia_sets() if active else valid_upgrades
	obsession_host_type = Enemy.EnemyType.UNKNOWN
	for host_type in upgrade_sets.keys():
		var data = upgrade_sets[host_type].pick_random()
		var upgrade = data[0] if data is Array else data
		var count = data[1] if data is Array else 1
		upgrades[upgrade] = count

func generate_hyperopia_sets():
	var hyperopia_upgrade_sets = {
		Enemy.EnemyType.SHOTGUN: [
			['reload_coroutine', 3],
			['stacked_shells', 2],
			'soldering_fingers'
		],
		Enemy.EnemyType.CHAIN: [
			'yorikiri',
			'hassotobi',
			'whiplash',
			'frayed_wires'
		],
		Enemy.EnemyType.WHEEL: [
			['spin_control', 2],
			['perforated_envelope', 2],
			['bulk_delivery', 2],
			'shaped_charges'
		],
		Enemy.EnemyType.FLAME: [
			['aerated_fuel_tanks', 2],
			'internal_combustion',
			'ultrasonic_nozzle',
			'alternative_coolant'
		],
		Enemy.EnemyType.SHIELD: [
			['improvised_projectiles', 2],
			['high_energy_orbit', 2],
			['spaghettification', 2],
			['entanglement', 2]
		],
		Enemy.EnemyType.SABER: [
			'ricochet_simulation',
			'true_focus',
			['composite_blades', 2]
		],
		Enemy.EnemyType.ARCHER: [
			'm_cracked_lens',
			'm_raytracing',
			'm_frequency_sweep',
			'm_shallow_focus',
			'slobberknocker_protocol'
		],
		Enemy.EnemyType.BAT: [
			'ruth_cherenkov_theorem',
			['multiball', 2],
			'tee_ball'
		]
	}
	if is_instance_valid(host):
		hyperopia_upgrade_sets.erase(host.enemy_type)
	return hyperopia_upgrade_sets

func generate_obsession_set(bot):
	
	var obsession_set = []
	
	match bot:
		"Steeltoe": 
			obsession_set = ['soldering_fingers', 'induction_barrel', 'ricochet_shells', ['reload_coroutine', 2], ['stacked_shells', 2], ['impulse_chamber', 3], ['ammo_conservation', 2]]
		"Router":
			if randf() > 0.5:
				obsession_set = ['shaped_charges', 'flow_state', ['spin_control', 3], ['preheated_tires', 2], ['express_delivery', 4]]
			else:
				obsession_set = ['unsecured_cargo', 'self_preservation_override', 'top_gear', ['perforated_envelope', 2], ['bulk_delivery', 2], ['careful_packing', 3], ['express_delivery', 2]]
		"Aphid": 
			obsession_set = ['alternative_coolant', 'second_sun',['aerated_fuel_tanks', 2], ['overpressure', 3], ['overclocked_cooling', 2]]
			if randf() > 0.5:
				obsession_set.append('internal_combustion')
			else:
				obsession_set.append('ultrasonic_nozzle')
		"Deadlift":
			if randf() > 0.5:
				obsession_set = ['hassotobi', 'whiplash', ['footwork_scheduler', 2], ['leg_day_hallucination', 5]]
			else:
				obsession_set = ['frayed_wires', 'yorikiri', 'finesse', ['cable_management', 2], ['weakpoint_database', 5]]
		"Collider":
			obsession_set = ['high_energy_orbit', ['improvised_projectiles', 2], ['spaghettification', 2], ['entanglement', 2], ['orbit_stabilization', 4]]
		"Tachi":
			obsession_set = ['true_focus', 'ricochet_simulation', ['composite_blades', 2], ['focused_pylons', 2], ['antigrav_sheath', 2], ['cloak_aerodynamics', 3]]
		"Thistle":
			obsession_set = [['sleight_of_hand', 2], ['vibro_shimmy', 2], ['overdraw', 2]]
			var beam_mod = ['cracked_lens', 'frequency_sweep', 'raytracing', 'shallow_focus'].pick_random()
			obsession_set.append("l_" + beam_mod)
			obsession_set.append("m_" + beam_mod)
			obsession_set.append("h_" + beam_mod)
		"Epitaph":
			obsession_set = ['ruth_cherenkov_theorem', 'tee_ball', ['multiball', 2], ['slither_sequencing', 3], ['compacted_orbs', 3]]
		_: # something has gone horribly wrong 
			obsession_set = [['obsession', 8]]
	
	return obsession_set

func set_variety_mult():
	if variety_list.size() < 2: return 1.0
	
	if golem_upgrades['habit'] and variety_list[0] == variety_list[1]:
		if variety_list.size() > 2 and variety_list[0] == variety_list[2]:
			variety_mult = -2.0
	
	variety_mult = 0.8
	for i in range(1, 4):
		if i >= variety_list.size() or not variety_list[0] == variety_list[i]:
			variety_mult += 0.2
		else:
			break

func convert_juice(amount):
	var post_mortem = host.dead
	if adv_boss_ai and post_mortem:
		amount *= 0.75
	if golem_upgrades["hubris"]:
		if post_mortem:
			amount *= 2.0
		else:
			amount /= 2.0
	if golem_upgrades["thorn"]:
		amount *= 1.33
	return amount

func set_indulgence_chain_targets():
	indulgence_chain_targets = get_valid_swap_targets()
	indulgence_chain_targets.sort_custom(func(a, b): return a.global_position.distance_squared_to(host.global_position) < b.global_position.distance_squared_to(host.global_position))
	indulgence_chain_targets.append(host)

func do_next_indulgence_chain_step():
	Util.remove_invalid(indulgence_chain_targets)
	Util.remove_custom(indulgence_chain_targets, func(a): return a.dead or a.is_player)
	
	if indulgence_chain_targets.is_empty():
		return
		
	attempt_trickshot(indulgence_chain_targets.pop_front())

func on_trickshot(bonuses):
	if golem_upgrades["compulsion"]:
		if (Fitness.Bonus.TRICKSHOT in bonuses or Fitness.Bonus.KAMIKAZE in bonuses) and not Fitness.Bonus.VANILLA in bonuses:
			local_juice = max_local_juice 
