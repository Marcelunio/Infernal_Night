#Meczył sie tu Kekls, wszelkie niepewności oraz pytania kierować do mnie...
extends Node2D
@onready var door = $Door

var can_leave: bool = false

const ROTATION_SPEED = 600.0

var door_state: int = 0 #0 = closed ; 1 = opening ; 2 = open
var target_rotation = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if door_state == 1:
		door.rotation_degrees = move_toward(door.rotation_degrees, target_rotation, ROTATION_SPEED * delta)
		
		if door.rotation_degrees == target_rotation:
			if target_rotation == 90.0:
				door_state = 2  # otwarty
			else:
				door_state = 0  # zamknięty

func _on_door_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_leave:
		if door_state == 0:
			target_rotation = 90.0
			door_state = 1

func _on_door_detect_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and can_leave:
		if door_state == 2:
			target_rotation = 0
			door_state = 1

func _on_inside_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("player").visible = false
		print("DEBUG - CarDoor - Odjechales")

func _on_inside_detect_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("player").visible = true
