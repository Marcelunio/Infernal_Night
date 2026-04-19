#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

var player: Node = null

func _ready() -> void:
	visible = false
	player = get_tree().get_first_node_in_group("player")
	player.death.connect(_player_death)

func _player_death(enemy_deaths, shots_fired, grenades_thrown):
	visible = true
	get_tree().paused = true
	var hours = int(PlayerData.play_time / 3600)
	var minutes = int(fmod(PlayerData.play_time, 3600) / 60)
	var seconds = int(fmod(PlayerData.play_time, 60))
	var play_time = "%02d:%02d:%02d" % [hours, minutes, seconds]
	$VBoxContainer/Label.text = "Play time: "+ play_time +"\nEnemies killed: " + str(enemy_deaths) + "\nShots fired: " + str(shots_fired) + "\nGrenades thrown: " + str(grenades_thrown)


func _on_button_pressed() -> void:
	visible = false
	#await player._fade(true)
	get_tree().paused = false
	GameState.pop_screen()
	GameState._CHANGE_ROOT("res://Scenes/Floors/Main/MainMenu.tscn")
