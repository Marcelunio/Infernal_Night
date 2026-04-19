#Tu gotuje Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#ten plik głównie slozy do przechowywania kluczowych informacji oraz ich zapisu i wczytywaniu
extends Node

#------SAVE------
const SAVE_PATH = "user://data.cfg"
var config = ConfigFile.new()
var play_time: float = 0.0
var runs: int = 0 

#------DUNGEON------
var dungeon_seed: int = 0
var floor_stage: String = "Start"
var floor_time: float = 0
var level: int = 0
var max_rooms: int = 0

#------PLAYER------
var max_hp: int = 6
var hp:int = 6
var coins: int = 0
var inventory_size:int = 3
var inventory_weapons: Array = []
var ammo_container: Dictionary = {
	"9mm": {"max": 50, "current": 50},
	"5.56mm": {"max": 200, "current": 200},
	"12gauge": {"max": 40, "current": 40},
	"7.62mm": {"max": 200, "current": 200}
}

#------STATS------
var enemy_deaths: int = 0
var shots_fired: int = 0
var grenades_thrown: int = 0

#------VAN------
var van_weapons: Array = ["pistol"]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _save() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	config.set_value("Current-Save", "play_time", play_time)
	config.set_value("Overall", "runs", runs)
	
	
	if get_tree().get_first_node_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		var inventory = player.get_node("InventoryMenager")
		
		max_hp = player.max_hp
		hp = player.hp
		coins = inventory.coins
		ammo_container = inventory.ammo_container.duplicate(true)
		inventory_size = inventory.weapon_container_capacity
		enemy_deaths = player.enemy_deaths
		shots_fired = player.shots_fired
		grenades_thrown = player.grenades_thrown
		
		config.set_value("Player", "max_hp", max_hp)
		config.set_value("Player", "hp", hp)
		
		config.set_value("Stats", "enemy_deaths", enemy_deaths)
		config.set_value("Stats", "shots_fired", shots_fired)
		config.set_value("Stats", "grenades_thrown", grenades_thrown)
		
		config.set_value("Player-Inventory", "coins", coins)
		config.set_value("Player-Inventory", "inventory_size", inventory_size)
		
		for i in range(inventory_size):
			var children = inventory.get_node("WeaponContainer").get_children()
			if i < children.size() and children[i] != null:
				config.set_value("Player-Inventory-Weapons", "slot%d" % i, children[i].weapon_name)
			else:
				config.set_value("Player-Inventory-Weapons", "slot%d" % i, "empty")
		
		config.set_value("Player-Inventory-Ammo", "9mm_max", ammo_container["9mm"]["max"])
		config.set_value("Player-Inventory-Ammo", "9mm_current", ammo_container["9mm"]["current"])
		config.set_value("Player-Inventory-Ammo", "5_56mm_max", ammo_container["5.56mm"]["max"])
		config.set_value("Player-Inventory-Ammo", "5_56mm_current", ammo_container["5.56mm"]["current"])
		config.set_value("Player-Inventory-Ammo", "12gauge_max", ammo_container["12gauge"]["max"])
		config.set_value("Player-Inventory-Ammo", "12gauge_current", ammo_container["12gauge"]["current"])
		config.set_value("Player-Inventory-Ammo", "7_62mm_max", ammo_container["7.62mm"]["max"])
		config.set_value("Player-Inventory-Ammo", "7_62mm_current", ammo_container["7.62mm"]["current"])
	
	if get_tree().get_first_node_in_group("VanStorage"):
		var van = get_tree().get_first_node_in_group("VanStorage")
		var children = van.get_children()
		for i in range(9):
			if i < children.size() and children[i] != null:
				config.set_value("Van", "slot%d" % i, children[i].weapon_name)
			else:
				config.set_value("Van", "slot%d" % i, "empty")
	
	config.set_value("Floor", "stage", floor_stage)
	config.set_value("Floor", "level", level)
	config.set_value("Floor", "max_rooms", max_rooms)
	config.set_value("Floor", "seed", dungeon_seed)
	
	
	config.save(SAVE_PATH)
	
func _check_save_file() -> bool:
	var err = config.load(SAVE_PATH)
	if err != OK:
		print("Brak pliku cfg, zostaną użyte domyślne wartości")
		return true
	return false

func _load() -> void:
	var err = config.load(SAVE_PATH)
	if err != OK:
		print("Brak pliku cfg, zostaną użyte domyślne wartości")
		_new_game()
		return
	print("Wczytywanie savefile")
	
	play_time = config.get_value("Current-Save", "play_time", play_time)
	runs = config.get_value("Overall", "runs", runs)
		
	max_hp = config.get_value("Player", "max_hp", max_hp)
	hp = config.get_value("Player", "hp", hp)
	
	enemy_deaths = config.get_value("Stats", "enemy_deaths", enemy_deaths)
	shots_fired = config.get_value("Stats", "shots_fired", shots_fired)
	grenades_thrown = config.get_value("Stats", "grenades_thrown", grenades_thrown)
	
	coins = config.get_value("Player-Inventory", "coins", coins)
	inventory_size = config.get_value("Player-Inventory", "inventory_size", inventory_size)
	
	inventory_weapons.clear()
	for i in range(inventory_size):
		inventory_weapons.append(config.get_value("Player-Inventory-Weapons", "slot%d" % i, "empty"))
	
	ammo_container["9mm"]["max"] = config.get_value("Player-Inventory-Ammo", "9mm_max", ammo_container["9mm"]["max"])
	ammo_container["9mm"]["current"] = config.get_value("Player-Inventory-Ammo", "9mm_current", ammo_container["9mm"]["current"])
	ammo_container["5.56mm"]["max"] = config.get_value("Player-Inventory-Ammo", "5_56mm_max", ammo_container["5.56mm"]["max"])
	ammo_container["5.56mm"]["current"] = config.get_value("Player-Inventory-Ammo", "5_56mm_current", ammo_container["5.56mm"]["current"])
	ammo_container["12gauge"]["max"] = config.get_value("Player-Inventory-Ammo", "12gauge_max", ammo_container["12gauge"]["max"])
	ammo_container["12gauge"]["current"] = config.get_value("Player-Inventory-Ammo", "12gauge_current", ammo_container["12gauge"]["current"])
	ammo_container["7.62mm"]["max"] = config.get_value("Player-Inventory-Ammo", "7_62mm_max", ammo_container["7.62mm"]["max"])
	ammo_container["7.62mm"]["current"] = config.get_value("Player-Inventory-Ammo", "7_62mm_current", ammo_container["7.62mm"]["current"])
	
	van_weapons.clear()
	for i in range(9):
		van_weapons.append(config.get_value("Van", "slot%d" % i, "empty"))
	
	floor_stage = config.get_value("Floor", "stage", floor_stage)
	level = config.get_value("Floor", "level", level)
	max_rooms = config.get_value("Floor", "max_rooms", max_rooms)
	dungeon_seed = config.get_value("Floor", "seed", dungeon_seed)
	
	floor_time = 0
	GameState._continue_game()

	
func _new_game() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	
	dungeon_seed = 0
	floor_stage = "Start"
	level = 0
	max_rooms = 0
	max_hp = 6
	coins = 0
	inventory_size = 3
	ammo_container = {
		"9mm": {"max": 50, "current": 50},
		"5.56mm": {"max": 200, "current": 200},
		"12gauge": {"max": 40, "current": 40},
		"7.62mm": {"max": 200, "current": 200}
	}
	van_weapons = ["pistol"]
	inventory_weapons = []
	runs += 1
	play_time = 0
	enemy_deaths = 0
	shots_fired = 0
	grenades_thrown = 0
	
	_save()

func _die():
	DirAccess.remove_absolute(SAVE_PATH)
