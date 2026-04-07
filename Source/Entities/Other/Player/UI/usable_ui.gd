#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
extends Control

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.pressed.connect(_on_any_button_pressed)
		
func _on_any_button_pressed() -> void:
	GameState._audio_click_UI(load("res://Sounds/SFX/UI/button_click.wav"))
