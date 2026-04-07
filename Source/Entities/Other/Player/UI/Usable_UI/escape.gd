#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

var Gameplay_UI: Node

func _ready() -> void:
	Settings.closed.connect(_on_settings_closed)
	Gameplay_UI = get_tree().get_first_node_in_group("player").get_node("Gameplay_UI")
	visible = false
	
func _input(event) -> void:
	if event.is_action_pressed("escape_menu"):
		if get_tree().paused and GameState.screen_stack.back() == "pause":
			GameState.pop_screen()
			visible = false
		elif GameState.screen_stack.is_empty() or GameState.screen_stack.back() != "settings":
			GameState.push_screen("pause")
			visible = true

func _on_resume_pressed() -> void:
	GameState.pop_screen()
	visible = false

func _on_save_pressed() -> void:
	pass 

func _on_settings_pressed() -> void:
	visible = false
	Settings.open()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameState.clear_screen_stack(false)
	get_tree().change_scene_to_file("res://Scenes/floors/Main/MainMenu.tscn")

#=========obsługa sygnałów=========:

func _on_settings_closed():
	visible = true
