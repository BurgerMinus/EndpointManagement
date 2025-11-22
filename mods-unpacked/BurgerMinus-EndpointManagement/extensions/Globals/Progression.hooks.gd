extends Object

func _ready(chain: ModLoaderHookChain):
	
	var progression = chain.reference_object as Progression
	
	chain.execute_next()
	
	var mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join("BurgerMinus-EndpointManagement")
	var tachi_shadow_skin = {
		"name" : "Shadow",
		"path" : mod_dir_path.path_join("ShadowTachiSkin.png"),
		"sprite_sheet_path" : mod_dir_path.path_join("skin_shadow_saberbot_99x137_updated.png"),
		"unlock_flag" : "em3_completed",
		"unlock_requirements" : "Beat a run with Endpoint Management set to 3",
		"flavour_text" : "Darkness.",
		"colour" : Color(0.33, 0.33, 0.33)
	}
	
	progression.tachi_skins.insert(5, tachi_shadow_skin)
	progression.all_skins.append(tachi_shadow_skin)
	GameManager.player_tachi_skin_path = progression.tachi_skins[SaveManager.settings.tachi_skin]["sprite_sheet_path"]

func on_run_completed(chain: ModLoaderHookChain):
	
	var progression = chain.reference_object as Progression
	
	chain.execute_next()
	print("TESTTESTEST")
	if Upgrades.get_antiupgrade_value('harder_bosses') >= 3:
		progression.unlock_skin("em3_completed")
