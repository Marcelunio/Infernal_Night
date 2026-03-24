extends CanvasLayer

signal closed

@onready var audio_vbox = $Control/Main/TabContainer/Audio/VBoxContainer

const BUSES = {
	"Master": "Master",
	"Music": "Music",
	"SFX": "SFX"
}

func _ready() -> void:
	visible = false
	
	_build_audio_list()

func _process(delta: float) -> void:
	pass
	
func open() -> void:
	visible = true
	
func close() -> void:
	closed.emit()
	visible = false

func _on_return_pressed() -> void:
	close()

func _build_audio_list():
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
		
		hbox.add_child(labelName)
		hbox.add_child(slider)
		hbox.add_child(labelValue)
		audio_vbox.add_child(hbox)

func _on_volume_changed(value, bus_name, labelValue) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(bus_name),
		linear_to_db(value)
	)
	
	labelValue.text = "%d %s" % [floor(value * 100), "%"]
