extends Control

var player: Node = null

func _ready() -> void:
	visible = false
	player = get_tree().get_first_node_in_group("player")
	player.death.connect(_player_death)

func _player_death(enemy_deaths, shots_fired, grenades_thrown):
	visible = true
	get_tree().paused = true
	$VBoxContainer/Label.text = "Enemies killed: " + str(enemy_deaths) + "\nShots fired: " + str(shots_fired) + "\nGrenades thrown: " + str(grenades_thrown)


func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameState.pop_screen()
	get_tree().change_scene_to_file("res://Scenes/floors/Main/MainMenu.tscn")
