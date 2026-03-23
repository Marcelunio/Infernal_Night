extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func _input(event) -> void:
	if event.is_action_pressed("escape_menu"):
		if get_tree().paused == true:
			get_tree().paused = false
			visible = false
		else:
			get_tree().paused = true
			visible = true

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_save_pressed() -> void:
	pass 

func _on_settings_pressed() -> void:
	pass 
	#get_tree().change_scene_to_file("res://Scenes/Main/Settings.tscn") bo nie mam menu

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scenes/Main/MainMenu.tscn")
