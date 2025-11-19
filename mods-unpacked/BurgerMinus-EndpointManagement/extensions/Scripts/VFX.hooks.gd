extends Object

static func emit_score_popup(chain: ModLoaderHookChain, pos, value, messages, dark_and_evil = false):
	if dark_and_evil:
		if GameManager.level_manager.current_floor.name == "Lvl3FloorBossFloor":
			var ira = GameManager.level_manager.current_floor.get_node("Ira")
			if ira.enemy_golem != null:
				value *= ira.enemy_golem.variety_mult
				value = round(value/10.0) * 10.0
	chain.execute_next([pos, value, messages, dark_and_evil])
