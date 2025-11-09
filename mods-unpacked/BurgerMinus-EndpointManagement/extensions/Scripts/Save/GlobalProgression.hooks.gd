extends Object

func deserialize(chain: ModLoaderHookChain, save_dict: Dictionary):
	
	var global_progression := chain.reference_object as GlobalProgression
	
	global_progression.progression_flags.antiupgrade_harder_bosses = 0
	
	chain.execute_next([save_dict])
