#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#ten plik jest uzywany glownie do wyznaczaniow stanu gry typu czy gra jest zapauzowana oraz ile jest na sobie nalozonych roznych okienek UI
#dodatkowo tez ten plik sluzy tez do przekazywania zmiennych pomiedzy plikami 
#jezeli bylo by to bardzo i to bardzo ciezkie / upierdliwe do zrobienia po przez sygnaly czy referencje
#lub po prostu nie mozliwe ze wzgledu na np. to ze znajduja sie w dwoch roznych rootach scen...
extends Node

var room_number:int #przekazywane miedzy rootem mainmenu a main (choice.gd -> dungeon.gd)

var screen_stack: Array = [] #kontroluje nakladki i pauzy UI

var audioClick: AudioStreamPlayer#dzwiek UI

func _ready() -> void:
	audioClick = AudioStreamPlayer.new()
	audioClick.process_mode = Node.PROCESS_MODE_ALWAYS
	audioClick.bus = "UI"
	add_child(audioClick)

func push_screen(screen_name: String):#screen_stack method
	screen_stack.append(screen_name)
	check_screen_stack()

func pop_screen():#screen_stack method
	screen_stack.pop_back()
	check_screen_stack()

func is_busy() -> bool:#screen_stack method
	return screen_stack.size() > 0

func check_screen_stack() -> void:#screen_stack method
	print(screen_stack)
	if screen_stack.size() > 0:
		get_tree().paused = true
		_set_gameplay_ui(false)
	else:
		get_tree().paused = false
		_set_gameplay_ui(true)

func clear_screen_stack(pause:bool) -> void:#screen_stack method
	if screen_stack.size() > 0:
		screen_stack.clear()
	
	get_tree().paused = pause

func contains_screen_stack(screen: String) -> bool:#screen_stack method
	if screen_stack.count(screen):
		return true
	else:
		return false

func _set_gameplay_ui(visibility: bool) -> void:#helper function for screen_stack method
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var gameplay_UI = player.get_node("Gameplay_UI")
		gameplay_UI._change(gameplay_UI, visibility)

func _audio_click_UI(stream: AudioStream) -> void:#UI audio player
	audioClick.stream = stream
	audioClick.play()

#---ROOT CHANGING---
func _CHANGE_ROOT(Path: String) -> void:
	get_tree().change_scene_to_file.call_deferred(Path)

func _continue_game() -> void:
	match PlayerData.floor_stage:
		"Dungeon":
			_CHANGE_ROOT("res://Scenes/Floors/Main/Main.tscn")
		"Shop":
			_CHANGE_ROOT("res://Scenes/Floors/Main/shop.tscn")
		"Choice":
			_CHANGE_ROOT("res://Scenes/Floors/Main/Choice.tscn")
		"Start", _:
			_CHANGE_ROOT("res://Scenes/Floors/Main/Choice.tscn")
