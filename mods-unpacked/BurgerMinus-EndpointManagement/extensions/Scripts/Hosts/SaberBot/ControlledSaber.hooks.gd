extends Object

func set_source(chain: ModLoaderHookChain, source_):
	
	var saber = chain.reference_object as ControlledSaber
	
	chain.execute_next([source_])
	
	if not is_instance_valid(GameManager.player) or not is_instance_valid(GameManager.player.true_host) or not is_instance_valid(saber.source): 
		return
	
	var s1 = saber.get_node("Sprite2D")
	var s2 = saber.get_node("Sprite2D2")
	var mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join("BurgerMinus-EndpointManagement")
	
	if saber.source.sprite.texture.resource_path.contains("shadow"):
		s1.texture = Util.get_cached_texture(mod_dir_path.path_join("Shadow_sword.png"))
		s2.texture = Util.get_cached_texture("res://Art/TinyTextureBlack.png")
	else:
		s1.texture = Util.get_cached_texture(mod_dir_path.path_join("Longer_sword.png"))
		s2.texture = Util.get_cached_texture("res://Art/TinyTexture.png")

func get_free_saber(chain: ModLoaderHookChain):
	
	var saber = chain.reference_object as ControlledSaber
	
	var free_saber = chain.execute_next()
	
	if not is_instance_valid(GameManager.player) or not is_instance_valid(GameManager.player.true_host) or not is_instance_valid(saber.source): 
		return free_saber
	
	if saber.source.sprite.texture.resource_path.contains("shadow"):
		var s1 = free_saber.get_node("Sprite2D")
		var s2 = free_saber.get_node("Sprite2D2")
		s1.texture = Util.get_cached_texture("res://Art/TinyTextureBlack.png")
		s2.texture = Util.get_cached_texture("res://Art/TinyTextureBlack.png")
	
	return free_saber
