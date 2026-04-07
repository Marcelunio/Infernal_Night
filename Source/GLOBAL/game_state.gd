#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Ten plik sluzy glownie do przekazywania zmiennych pomiedzy plikami 
#jezeli bylo by to bardzo i to bardzo ciezkie / upierdliwe do zrobienia po przez sygnaly czy referencje
#lub po prostu nie mozliwe ze wzgledu na np. to ze znajduja sie w dwoch roznych rootach scen...
extends Node

var room_number:int #przekazywane miedzy rootem mainmenu a main (choice.gd -> dungeon.gd)

var screen_stack: Array = [] #kontroluje nakladki i pauzy UI

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

func clear_screen_stack(pause:bool) -> void:
	if screen_stack.size() > 0:
		screen_stack.clear()
	
	get_tree().paused = pause

func _set_gameplay_ui(visibility: bool) -> void:#helper function for screen_stack method
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var gameplay_UI = player.get_node("Gameplay_UI")
		gameplay_UI._change(gameplay_UI, visibility)
