#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Node2D


@onready var clerk_sprite = $Clerk

@onready var shop_UI = $ShopUI 

var player_rotate: bool = false
var can_open_shop_UI: bool = false

var player: Node
var inventory: Node

func _ready() -> void:
	call_deferred("connect_signals")

func connect_signals() -> void:
	player= get_tree().get_first_node_in_group("player")
	inventory = player.get_node("InventoryMenager")

func _process(delta: float) -> void:
	if not player_rotate:
		return
		
	clerk_sprite.rotation = (player.global_position - global_position).angle() + PI/2

func _input(event) -> void:
	if event.is_action_pressed("interaction") and can_open_shop_UI:
		if get_tree().paused and GameState.screen_stack.back() == "shopUI":
			GameState.pop_screen()
			shop_UI._close()
			if inventory.current_weapon != null:
				player.get_node("animation/top").play("pickup_"+inventory.current_weapon.weapon_name)
			else:
				player.get_node("animation/top").play("unarmed")
		elif not GameState.is_busy():
			GameState.push_screen("shopUI")
			shop_UI._open()

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body == player:
		can_open_shop_UI = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body == player:
		can_open_shop_UI = false

func _on_rotate_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_rotate = true

func _on_rotate_area_body_exited(body: Node2D) -> void:
	if body == player:
		player_rotate = false
