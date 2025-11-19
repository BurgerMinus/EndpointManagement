extends "res://Scripts/UI/DebugConsole.gd"

func on_text_submitted(txt):
	var tokens = txt.split(' ')
	match tokens[0]:
		"activate":
			set_golem_upgrade(tokens[1] if tokens.size() == 2 else "ERROR", true)
		"deactivate":
			set_golem_upgrade(tokens[1] if tokens.size() == 2 else "ERROR", false)
		"setseed":
			set_golem_upgrade_seed(tokens[1] if tokens.size() == 2 else 0)
	super(txt)

func set_golem_upgrade(upgrade, active):
	if GameManager.level_manager.current_floor.name == "Lvl3FloorBossFloor":
			var ira = GameManager.level_manager.current_floor.get_node("Ira")
			if ira.enemy_golem != null:
				ira.enemy_golem.set_golem_upgrade(upgrade, active)

func set_golem_upgrade_seed(seed):
	var golem_upgrade_seed = seed.to_int() % 8 if seed.is_valid_int() else -1
	if GameManager.level_manager.current_floor.name == "Lvl3FloorBossFloor":
			var ira = GameManager.level_manager.current_floor.get_node("Ira")
			if ira.enemy_golem != null:
				ira.enemy_golem.golem_upgrade_seed = golem_upgrade_seed
