#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState._CHANGE_ROOT("res://Scenes/Floors/Main/Choice.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
