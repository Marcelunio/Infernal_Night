#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
extends Control

func _ready() -> void:
	call_deferred("_connects_signals")
	
func _connects_signals() -> void:
	GameState.player_death.connect(_change.bind(self, false))
	
func _change(node: Node, visibility: bool) -> void:
	node.visible = visibility
	for child in node.get_children():
		if child is CanvasLayer:
			child.visible = visibility
