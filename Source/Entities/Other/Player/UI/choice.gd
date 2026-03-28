extends Control

const ROOMS = {
	"easy": [6,9],
	"medium": [10,13],
	"hard": [14,17]
}

func _ready() -> void:
	visible = false
	
	for room in ROOMS:
		var label = Label.new()
		var button = Button.new()
		var v_box = VBoxContainer.new()
		
		label.text = str(room) + ":\n minimum rooms: " + str(ROOMS[room][0]) + "\n maximum rooms: " + str(ROOMS[room][1])
		button.text = "play"

		button.pressed.connect(_pressed.bind(room))

		v_box.add_child(label)
		v_box.add_child(button)
		$HBoxContainer.add_child(v_box)
	
func start() -> void:
	visible = true
	
func _pressed(room) -> void:
	GameState.minimum_rooms = ROOMS[room][0]
	GameState.maximum_rooms = ROOMS[room][1]
	get_tree().change_scene_to_file("res://Scenes/Floors/Main/Main.tscn")
