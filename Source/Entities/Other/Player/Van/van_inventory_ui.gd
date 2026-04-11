extends CanvasLayer

var open: bool = false

#UI
@onready var GridVan = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/GridVan
@onready var GridPlayer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/GridPlayer

@export var van_columns: int

#variables pointing to other scenes
var player: Node
var inventory: Node

#weapons
@export var weapon_scenes: Array[PackedScene] = []
var dict_weapons: Dictionary = {}

const DAD_SCENE = preload("res://Scenes/Entities/Other/Van/DaDContainer.tscn")

func _ready() -> void:
	visible = false
	
	for x in weapon_scenes:
		var instance = x.instantiate()
		dict_weapons[instance.weapon_name] = x
		instance.free()
	
	call_deferred("_create")

func _create() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_connect_signals()
	_build_UI()

func _connect_signals() -> void:
	player = get_parent().player
	inventory = get_parent().inventory

func _build_UI() -> void:
	GridVan.columns = van_columns
	GridPlayer.columns = 3
	var storage = self.get_node("WeaponContainer")
	
	for key in dict_weapons.keys():
		var x = DAD_SCENE.instantiate()
		var instance = dict_weapons[key].instantiate()
		instance.visible = false
		storage.add_child(instance)
		x.texture = instance.sprite
		x.weapon_name = key
		x.weapon = instance
		x.player = player
		x.inventory = inventory
		x.storage = storage
		GridVan.add_child(x)
		x._create()
		
	for i in range(inventory.weapon_container_capacity):
		var x = DAD_SCENE.instantiate()
		x.player_inventory = true
		x.player = player
		x.inventory = inventory
		x.storage = storage
		GridPlayer.add_child(x)
		
func _open() -> void:
	visible = true
	open = true
	_refresh_player_inventory()

func _close() -> void:
	visible = false
	open = false

func _count_player_columns(capacity) -> int:
	if capacity % 3 != 0:
		return int(capacity / 3) + 1
	else:
		return capacity / 3


func _refresh_player_inventory() -> void:
	for slot in GridPlayer.get_children():
		slot.weapon_name = ""
		slot.texture = null
		slot.weapon = null
		slot._create()
	
	for i in range(inventory.weapon_container.size()):
		var slot = GridPlayer.get_child(i)
		var weapon = inventory.weapon_container[i]
		slot.weapon_name = weapon.weapon_name
		slot.texture = weapon.sprite
		slot.weapon = weapon
		slot._create()
