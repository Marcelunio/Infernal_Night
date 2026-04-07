#Meczy sie tu Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
extends Area2D

#tileSets
@onready var tile_active: Node = $TileActive
@onready var tile_inactive: Node = $TileInactive

#player and its children
var player: Node
var inventory: Node
var gameplay_UI: Node

#VanInventoryUI
@onready var VanInventoryUI: Node = $VanInventoryUI

var can_open_inventory: bool = false

func _ready() -> void:
	tile_active.visible = false
	call_deferred("_connect_signals")

func _connect_signals() -> void:
	player = get_tree().get_first_node_in_group("player")
	inventory = player.get_node("InventoryMenager")
	gameplay_UI = player.get_node("Gameplay_UI")

func _input(event) -> void:
	if event.is_action_pressed("interaction") and can_open_inventory:
		if get_tree().paused and GameState.screen_stack.back() == "vanInventory":
			GameState.pop_screen()
			VanInventoryUI._close()
		elif not GameState.is_busy():
			GameState.push_screen("vanInventory")
			VanInventoryUI._open()
	
	if event.is_action_pressed("escape_menu") and can_open_inventory and GameState.is_busy():
		if VanInventoryUI.open:
			print("zamykam")
			VanInventoryUI._close()
		if not VanInventoryUI.open:
			VanInventoryUI._open()
			print("otwieram")

func _on_body_entered(body: Node2D) -> void:
	if not body == player:
		return
	
	tile_inactive.visible = false
	tile_active.visible = true
	can_open_inventory = true

func _on_body_exited(body: Node2D) -> void:
	if not body == player:
		return
	
	tile_active.visible = false
	tile_inactive.visible = true
	can_open_inventory = false
	
