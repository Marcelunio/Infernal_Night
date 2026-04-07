#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends CanvasLayer

signal closed

@onready var audio_vbox: Node = $Control/Main/TabContainer/Audio/VBoxContainer
@onready var controlsVBox: Node = $Control/Main/TabContainer/Controls/VBoxContainer
@onready var videoVBox: Node = $Control/Main/TabContainer/Video/VBoxContainer

var Gameplay_UI: Node

const BUSES = {
	"Master": "Master",
	"Music": "Music",
	"SFX": "SFX"
}

const KEY_BINDS = {
	"Move up": "move_up",
	"Move down": "move_down",
	"Move left": "move_left",
	"Move right": "move_right",
	"Dash": "dash",
	"Interaction": "interaction",
	"Shoot": "shoot",
	"Throw": "throw",
	"Pick up": "pick_up",
	"Reload": "reload",
	"Pause menu": "escape_menu"
}

const RESOLUTIONS = {
	"854 x 480": Vector2i(854, 480),
	"1280 x 720": Vector2i(1280, 720),
	"1920 x 1080": Vector2i(1920, 1080),
	"2560 x 1440": Vector2i(2560, 1440),
	"3840 x 2160": Vector2i(3840, 2160),
}

const WINDOW_TYPES = {
	"Full screen": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"Maximized": DisplayServer.WINDOW_MODE_MAXIMIZED
}

var buttons = {}

#------RESET------
var after_reset:bool = false

#------CONTROLS------
var waitingForInput:bool = false
var currentAction: String = ""
var currentButton: Node = null
var buttonsArray: Array = []

#------SAVE------
const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
	visible = false
	
	_load_settings()
	_build_audio_list()
	_build_video_list()
	_build_controls_list()
	
func open() -> void:
	GameState.push_screen("settings")
	visible = true
	
func close() -> void:
	closed.emit()
	GameState.pop_screen()
	visible = false

func _on_return_pressed() -> void:
	close()

func _input(event) -> void:
	if not waitingForInput:
		return
	
	if event is InputEventMouseMotion:
		return
	
	InputMap.action_erase_events(currentAction)
	InputMap.action_add_event(currentAction, event)
	config.set_value("Controls", currentAction, event)
	config.save(SAVE_PATH)
	
	currentButton.text = event.as_text()
	waitingForInput = false
	currentButton = null
	get_viewport().set_input_as_handled()

func _load_settings():
	var err = config.load(SAVE_PATH)
	if err != OK:
		print("Brak pliku cfg, zostaną użyte domyślne wartości")
		
	for bus_label in BUSES.values():
		var currentValue = db_to_linear(AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index(BUSES[bus_label])
		))
		var value = config.get_value("Audio", BUSES[bus_label], currentValue)
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(BUSES[bus_label]),
			linear_to_db(value)
		)
		if after_reset:
			buttons[bus_label].value = 1.0
			buttons[bus_label].queue_redraw()

	var res = config.get_value("Video", "resolution", DisplayServer.window_get_size())
	DisplayServer.window_set_size(res)
	
	var mode = config.get_value("Video", "window_type", DisplayServer.window_get_mode())
	DisplayServer.window_set_mode(mode)
	
	for action in KEY_BINDS.values():
		if config.has_section_key("Controls", action):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, config.get_value("Controls", action, null))
	
	after_reset = false

func _build_audio_list() -> void:
	for label_text in BUSES:
		var bus_name = BUSES[label_text]
		
		var hbox = HBoxContainer.new()
		var labelName = Label.new()
		var labelValue = Label.new()
		labelName.text = label_text
		
		var slider = HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 2.0
		slider.step = 0.01
		slider.custom_minimum_size.x = 150.00
		var currentValue = db_to_linear(AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index(bus_name)
		))
		slider.value = currentValue
		
		labelValue.text = "%d %s" % [floor(currentValue * 100), "%"]
		
		slider.value_changed.connect(_on_volume_changed.bind(bus_name, labelValue))
		slider.drag_ended.connect(_on_valume_drag_ended.bind(slider, bus_name))
		
		hbox.add_child(labelName)
		hbox.add_child(slider)
		hbox.add_child(labelValue)
		audio_vbox.add_child(hbox)
		
		buttons[label_text] = slider

func _build_video_list() -> void:
	var hBox = HBoxContainer.new()
	var label = Label.new()
	var dropdown = OptionButton.new()
	
	label.text = "Resolution: "
	for res in RESOLUTIONS:
		if DisplayServer.screen_get_size() >= RESOLUTIONS[res]:
			dropdown.add_item(res)
	
	dropdown.item_selected.connect(_on_resolution_selected)
	dropdown.selected = get_index_by_value(RESOLUTIONS, DisplayServer.window_get_size())
	
	hBox.add_child(label)
	hBox.add_child(dropdown)
	videoVBox.add_child(hBox)
	
	buttons["Resolution"] = dropdown
	
	hBox = HBoxContainer.new()
	label = Label.new()
	dropdown = OptionButton.new()
	
	label.text = "Window mode: "
	for mode in WINDOW_TYPES:
		dropdown.add_item(mode)
	
	dropdown.item_selected.connect(_on_windowType_selected)
	dropdown.selected = get_index_by_value(WINDOW_TYPES, DisplayServer.window_get_mode())
	
	hBox.add_child(label)
	hBox.add_child(dropdown)
	videoVBox.add_child(hBox)
	
	buttons["Window_types"] = dropdown

func _build_controls_list() -> void:
	for labelText in KEY_BINDS:
		var keyBind = KEY_BINDS[labelText]
		
		var hBox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		label.text = labelText
		button.text = InputMap.action_get_events(keyBind)[0].as_text()
		button.pressed.connect(_on_keyBind_pressed.bind(keyBind, button))
		
		buttonsArray.append(button)
		hBox.add_child(label)
		hBox.add_child(button)
		controlsVBox.add_child(hBox)
	
	var resetButton = Button.new()
	resetButton.text = "Return to original"
	resetButton.pressed.connect(_on_resetKeyBinds_pressed)
	controlsVBox.add_child(resetButton)


func _on_volume_changed(value, bus_name, labelValue) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(bus_name),
		linear_to_db(value)
	)
	
	labelValue.text = "%d %s" % [floor(value * 100), "%"]

func _on_valume_drag_ended(value_changed, slider, bus_name) -> void:
	if value_changed:
		config.set_value("Audio", bus_name, slider.value)
		config.save(SAVE_PATH)

func _on_keyBind_pressed(keyBind, button) -> void:
	waitingForInput = true
	currentButton = button
	currentAction = keyBind
	button.text = "..."
	
func _on_resetKeyBinds_pressed() -> void:
	InputMap.load_from_project_settings()
	
	if config.has_section("Controls"):
		config.erase_section("Controls")
		config.save(SAVE_PATH)
	
	var keys = KEY_BINDS.keys()
	for i in keys.size():
		buttonsArray[i].text = InputMap.action_get_events(KEY_BINDS[keys[i]])[0].as_text()
		
func _on_resolution_selected(index) -> void:
	var res = RESOLUTIONS.keys()[index]
	DisplayServer.window_set_size(RESOLUTIONS[res])
	config.set_value("Video", "resolution", RESOLUTIONS[res])
	config.save(SAVE_PATH)

func _on_windowType_selected(index) -> void:
	var mode = WINDOW_TYPES.keys()[index]
	DisplayServer.window_set_mode(WINDOW_TYPES[mode])
	config.set_value("Video", "window_type", WINDOW_TYPES[mode])
	config.save(SAVE_PATH)
	
	if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		buttons["Resolution"].disabled = true
	else:
		buttons["Resolution"].disabled = false

func get_index_by_value(dict: Dictionary, value) -> int:
	var keys = dict.keys()
	for i in keys.size():
		if dict[keys[i]] == value:
			return i
	return -1  # nie znaleziono

func _on_reset_pressed() -> void:
	after_reset = true
	DirAccess.remove_absolute(SAVE_PATH)
	_on_resetKeyBinds_pressed()
	_load_settings()


func _on_control_resized() -> void:
	$Control.theme.default_font_size = DisplayServer.window_get_size().y/36
