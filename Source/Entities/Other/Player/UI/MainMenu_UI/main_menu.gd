#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

@onready var continue_button: Node  = $VBoxContainer/continue

func _ready() -> void:
	Settings.closed.connect(_on_settings_closed)
	$Choice.from_main_menu = true
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.pressed.connect(_on_any_button_pressed)
	DisplayServer.window_get_size()
	continue_button.disabled = PlayerData._check_save_file()
	
func _on_new_game_pressed() -> void:
	PlayerData._new_game()
	$Choice.start()

func _on_continue_pressed() -> void:
	PlayerData._load()

func _on_settings_pressed() -> void:
	visible = false
	Settings.open()

func _on_exit_pressed() -> void:
	get_tree().quit()
	
#=========obsługa sygnałów=========:

func _on_settings_closed():
	visible = true

func _on_any_button_pressed() -> void:
	GameState._audio_click_UI(load("res://Sounds/SFX/UI/button_click.wav"))
