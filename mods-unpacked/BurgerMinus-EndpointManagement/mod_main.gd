extends Node

const EM_DIR := "BurgerMinus-EndpointManagement"

var mod_dir_path := ""

func _init() -> void:
	
	Upgrades.antiupgrades['harder_bosses'] = {
		'name' : "Endpoint Management",
		'desc' : "Greatly increases the difficulty of +1 boss per stack",
		'increase_per_rank' : 1,
		'decreasing' : false,
		'value_per_rank': [2.0, 3.0, 5.0], 
		'max_rank' : 3,
		'percentage' : false,
		'progression_flag' : 'antiupgrade_harder_bosses',
		'daily_run_compatible' : false
	}
	
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(EM_DIR)
	
	ModLoaderMod.install_script_hooks("res://Scripts/Save/GlobalProgression.gd", mod_dir_path.path_join("extensions/Scripts/Save/GlobalProgression.hooks.gd"))
	install_em1()
	install_em2()
	install_em3()

func install_em1():
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/Bosses/MountainBoss.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/MountainBoss.hooks.gd"))
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/MountainBossAI.gd"))

func install_em2():
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/Bosses/Lv2/CityBoss.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/Lv2/CityBoss.hooks.gd"))
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/Lv2/CityBossAI.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/Bosses/Lv2/CityBossOrb.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/Lv2/CityBossOrb.hooks.gd"))
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/Lv2/CityBossOrbAI.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/Bosses/Lv2/CityBossOrbController.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/Lv2/CityBossOrbController.hooks.gd"))

func install_em3():
	
	# boss
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/Hosts/Bosses/Lv3/GolemBoss.gd"))
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/Cutscenes/Boss3/Boss3Phase2Cutscene.gd"))
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/UI/DebugConsole.gd"))
	
#	# bots
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/ShotgunBot/ShotgunAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/ShotgunBot/ShotgunAI.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/WheelBot/WheelBotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/WheelBot/WheelBotAI.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/FlameBot/FlameBotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/FlameBot/FlameBotAI.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/ChainBot/ChainbotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/ChainBot/ChainbotAI.hooks.gd")); ModLoaderMod.install_script_hooks("res://Scripts/Hosts/ChainBot/ChainBot.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/ChainBot/ChainBot.hooks.gd")) # if youre reading this buy supporter pack
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/ShieldBot/ShieldBotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/ShieldBot/ShieldBotAI.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/SaberBot/SaberBotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/SaberBot/SaberBotAI.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/ArcherBot/ArcherBotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/ArcherBot/ArcherBotAI.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/BatBot/BatBotAI.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/BatBot/BatBotAI.hooks.gd"))
	
	# habit
	ModLoaderMod.install_script_hooks("res://Scripts/VFX.gd", mod_dir_path.path_join("extensions/Scripts/VFX.hooks.gd"))
	
	# compulsion
	ModLoaderMod.install_script_hooks("res://Scripts/Player/Fitness.gd", mod_dir_path.path_join("extensions/Scripts/Player/Fitness.hooks.gd"))	
	
	# deviance
	ModLoaderMod.install_script_hooks("res://Scripts/Violence/Structs/Attack.gd", mod_dir_path.path_join("extensions/Scripts/Violence/Structs/Attack.hooks.gd"))
	
#	# scorn (stupid scene reloading bullshit not working thank you godot 4.2)
#	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Art/UI/SwapLine.gd"))
#	ModLoaderMod.refresh_scene("res://Scenes/UI/SwapLine.tscn")
	
	# euphoria (timescale is complicated okay)
	ModLoaderMod.install_script_extension(mod_dir_path.path_join("extensions/Scripts/Hosts/ChainBot/Grapple.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/BatBot/EnergyBall.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/BatBot/EnergyBall.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Violence/Projectile.gd", mod_dir_path.path_join("extensions/Scripts/Violence/Projectile.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://Scripts/Hosts/Enemy.gd", mod_dir_path.path_join("extensions/Scripts/Hosts/Enemy.hooks.gd"))

