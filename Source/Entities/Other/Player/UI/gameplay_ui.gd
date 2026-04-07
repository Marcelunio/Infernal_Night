#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
extends Control

func _ready() -> void:
	pass

func _change(node: Node, visibility: bool) -> void:
	node.visible = visibility
	for child in node.get_children():
		if child is CanvasLayer:
			child.visible = visibility
