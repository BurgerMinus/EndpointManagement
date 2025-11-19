extends "res://Scripts/Hosts/ChainBot/Grapple.gd"

func _physics_process(delta):
	var golem_boss = source.prev_enemy_golem
	if source.was_recently_enemy_golem() and golem_boss.golem_upgrades["euphoria"] and golem_boss.euphoria_active:
		delta *= golem_boss.euphoria_multiplier
	super(delta)
