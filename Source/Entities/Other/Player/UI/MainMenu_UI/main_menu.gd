#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

func _ready() -> void:
	Settings.closed.connect(_on_settings_closed)
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.pressed.connect(_on_any_button_pressed)
	DisplayServer.window_get_size()
	
func _on_new_game_pressed() -> void:
	$Choice.start()
	#get_tree().change_scene_to_file("res://Scenes/TestRooms/Main.tscn")

func _on_load_pressed() -> void:
	pass
	#mysle nad prostym system ktory by zapisywal w notatniczku typu level1 = 1 level2 = 1 level3 = 0 itd....

func _on_settings_pressed() -> void:
	visible = false
	Settings.open()

func _on_exit_pressed() -> void:
	get_tree().quit()
#=========obsługa sygnałów=========:

func _on_settings_closed():
	visible = true

func _on_any_button_pressed() -> void:
	GameState._audio_click_UI(load("res://Sounds/SFX/UI/button_click.wav"))
