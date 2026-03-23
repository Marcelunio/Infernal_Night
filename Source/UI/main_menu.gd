#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

func _ready() -> void:
	pass # Replace with function body.

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")

func _on_load_pressed() -> void:
	pass
	#mysle nad prostym system ktory by zapisywal w notatniczku typu level1 = 1 level2 = 1 level3 = 0 itd....

func _on_settings_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://Scenes/Main/Settings.tscn") bo nie mam menu

func _on_exit_pressed() -> void:
	get_tree().quit()
