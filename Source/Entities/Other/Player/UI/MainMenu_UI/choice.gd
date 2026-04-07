extends Control

const ROOMS = {
	"easy": 8,
	"medium": 12,
	"hard": 16
}

func _ready() -> void:
	visible = false
	
	for room in ROOMS:
		var label = Label.new()
		var button = Button.new()
		var v_box = VBoxContainer.new()
		
		label.text = str(room) + ":\n Rooms: " + str(ROOMS[room])
		button.text = "play"

		button.pressed.connect(_pressed.bind(room))
		button.add_to_group("Buttons")

		v_box.add_child(label)
		v_box.add_child(button)
		$HBoxContainer.add_child(v_box)
	
func start() -> void:
	visible = true
	
func _pressed(room) -> void:
	GameState.room_number = ROOMS[room]
	get_tree().change_scene_to_file("res://Scenes/Floors/Main/Main.tscn")
