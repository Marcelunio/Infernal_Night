#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

var from_main_menu: bool = false

const ROOMS = {
	"easy": 8,
	"medium": 12,
	"hard": 16
}

func _ready() -> void:
	await get_tree().physics_frame
	if not from_main_menu:
		PlayerData.floor_stage = "Choice"
		var audio_node = AudioStreamPlayer.new()
		audio_node.stream = load("res://Sounds/Music/Main_menu.ogg")
		audio_node.autoplay = true
		audio_node.bus = "Music"
		add_child(audio_node)
		audio_node.play()
	else:
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
	for Vbox in $HBoxContainer.get_children():
		for control in Vbox.get_children():
			control.add_theme_font_size_override("font_size",DisplayServer.window_get_size().y/36)
	
func _pressed(room) -> void:
	PlayerData.max_rooms = ROOMS[room]
	PlayerData.level += 1
	PlayerData.floor_time = 0
	GameState._CHANGE_ROOT("res://Scenes/Floors/Main/Main.tscn")
