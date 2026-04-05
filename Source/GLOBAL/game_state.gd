extends Node

var room_number:int 

var screen_stack: Array = []

func push_screen(screen_name: String):
	screen_stack.append(screen_name)

func pop_screen():
	screen_stack.pop_back()

func is_busy() -> bool:
	return screen_stack.size() > 0
	
