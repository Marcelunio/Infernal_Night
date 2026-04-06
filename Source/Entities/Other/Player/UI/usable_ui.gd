#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
extends Control

var Gameplay_UI: Node

func _ready() -> void:
	Gameplay_UI = get_parent().get_node("Gameplay_UI")
	call_deferred("_connects_signals")
	
func _connects_signals() -> void:
	GameState.player_death.connect(_player_died.bind(Gameplay_UI))
	
func _player_died(node: Node) -> void:
	for x in node.get_children():
		x.visible = false
		if x.get_children() != []:
			_player_died(x)
	
