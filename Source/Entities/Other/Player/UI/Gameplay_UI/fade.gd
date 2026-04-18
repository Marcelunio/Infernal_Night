#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

var alpha: float = 0

func _ready() -> void:
	pass

func fade_out() -> void:
	var tw = create_tween()
	tw.tween_property($ColorRect, "color:a", 1.0, 2.0)
	await tw.finished

func fade_in() -> void:
	var tw = create_tween()
	tw.tween_property($ColorRect, "color:a", 0.0, 2.0)
	await tw.finished
