extends Node2D

signal door_entered(direction: String)

func _ready():
	for child in $Doors.get_children():
		if child is Area2D:
			child.body_entered.connect(_on_any_door_entered.bind(child.name))

func _on_any_door_entered(body: Node2D, door_name: String):
	if body.name != "Player":
		return

	var direction = ""
	match door_name:
		"DoorUp": direction = "up"
		"DoorDown": direction = "down"
		"DoorLeft": direction = "left"
		"DoorRight": direction = "right"

	print("Player entered door: ", direction)

	emit_signal("door_entered", direction)
