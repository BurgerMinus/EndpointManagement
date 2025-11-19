extends "res://Scripts/Cutscenes/Boss3/Boss3Phase2Cutscene.gd"

const GolemUpgradePopup = preload('res://Scenes/UI/GolemItemPopup.tscn')

func spawn_upgrade_popup(upgrade):
	if Upgrades.is_golem_upgrade(upgrade):
		popup_timer = 0.5*pow(1.0/popups_spawned, 0.5)
		popups_spawned += 1
	
		var popup = GolemUpgradePopup.instantiate()
		popup.set_upgrade(upgrade)
		popup.global_position = Vector2.DOWN*500 + Vector2((randf() - 0.5)*1000, (randf() - 0.5)*200)
		popup.z_index = 100
		GameManager.HUD.stacking_popups.add_child(popup)
		popups.append([popup, 0.0])
	else:
		super(upgrade)
