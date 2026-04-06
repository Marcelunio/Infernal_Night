#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Ten plik sluzy glownie do przekazywania zmiennych pomiedzy plikami 
#jezeli bylo by to bardzo i to bardzo ciezkie / upierdliwe do zrobienia po przez sygnaly czy referencje
#lub po prostu nie mozliwe ze wzgledu na np. to ze znajduja sie w dwoch roznych rootach scen...
extends Node

var room_number:int #przekazywane miedzy rootem mainmenu a main (choice.gd -> dungeon.gd)

var screen_stack: Array = [] #kontroluje nakladki i pauzy UI

signal player_death() #sygnal wysylany ui informujac o smierci gracza

func push_screen(screen_name: String):#screen_stack method
	screen_stack.append(screen_name)

func pop_screen():#screen_stack method
	screen_stack.pop_back()

func is_busy() -> bool:#screen_stack method
	return screen_stack.size() > 0

func dead() -> void:#Sygnalizuje ui smierc gracza
	emit_signal("player_death")
	
