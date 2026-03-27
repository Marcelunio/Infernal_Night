#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

func _ready() -> void:
	Settings.closed.connect(_on_settings_closed)
	visible = false
	
func _input(event) -> void:
	if event.is_action_pressed("escape_menu"):
		if get_tree().paused and GameState.screen_stack.back() == "pause":
			GameState.pop_screen()
			get_tree().paused = false
			visible = false
		elif not GameState.is_busy():
			GameState.push_screen("pause")
			get_tree().paused = true
			visible = true

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_save_pressed() -> void:
	pass 

func _on_settings_pressed() -> void:
	visible = false
	Settings.open()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scenes/floors/Main/MainMenu.tscn")

#=========obsługa sygnałów=========:

func _on_settings_closed():
	visible = true
