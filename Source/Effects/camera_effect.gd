#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...\
extends ColorRect

func _process(delta: float) -> void:
	material.set_shader_parameter("time", Time.get_ticks_msec() * 0.001)
