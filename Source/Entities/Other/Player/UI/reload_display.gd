extends Control

var player: Node
var inventory: Node
@onready var animation: Node = $AnimatedSprite2D

func _ready() -> void:
	visible = false
	player = get_tree().get_first_node_in_group("player")
	inventory = player.get_node("InventoryMenager")

	call_deferred("_connect_signals")
	
func _process(delta: float) -> void:
	rotation = -player.rotation
	global_position = player.global_position + Vector2(0,-40)

func _connect_signals() -> void:
	inventory.UI_Reload.connect(_reload_start)
	print("DEBUG LACZY")

func _reload_start(weapon) -> void:
	visible = true
	animation.speed_scale = 1.0/weapon.reload_time
	animation.play("reload")

func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false
	animation.speed_scale = 1.0
