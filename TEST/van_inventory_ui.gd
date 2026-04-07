extends CanvasLayer

var open: bool = false

func _ready() -> void:
	visible = false

func _open() -> void:
	visible = true
	open = true

func _close() -> void:
	visible = false
	open = false
