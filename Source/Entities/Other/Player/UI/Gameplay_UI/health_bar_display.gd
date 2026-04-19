#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends PanelContainer

var player: Node
@onready var h_box = $MarginContainer/HBoxContainer

@export var texture_full: Texture2D
@export var texture_half: Texture2D
@export var texture_empty: Texture2D

func _ready() -> void:
	visible = true
	player = get_tree().get_first_node_in_group("player")
	call_deferred("_connect_signals")

func _connect_signals() -> void:
	player.UI_HealthBarDisplay.connect(_health_bar_create)
	
func _health_bar_create(max_hp, hp) -> void:
	for child in h_box.get_children():
		child.queue_free()
	
	if hp % 2 == 0:
		_whole_health_create(max_hp, hp)
	else:
		_partial_health_create(max_hp, hp)

func _whole_health_create(max_hp, hp) -> void:
	var health_containers = max_hp / 2
	var empty_health_containers = (max_hp - hp) / 2
	var full_health_containers = health_containers - empty_health_containers
	
	for i in range(health_containers):
		var texture_rect = TextureRect.new()
		if i < full_health_containers:
			texture_rect.texture = texture_full
		elif i < full_health_containers + empty_health_containers:
			texture_rect.texture = texture_empty
		
		h_box.add_child(texture_rect)

func _partial_health_create(max_hp, hp) -> void:
	var health_containers = max_hp / 2
	var full_health_containers = int(hp / 2)
	var empty_health_containers = int((max_hp - hp) / 2)
	var partial_health_containers = health_containers - full_health_containers - empty_health_containers
	
	for i in range(health_containers):
		var texture_rect = TextureRect.new()
		if i < full_health_containers:
			texture_rect.texture = texture_full
		elif i < full_health_containers + partial_health_containers:
			texture_rect.texture = texture_half
		elif i < full_health_containers + partial_health_containers + empty_health_containers:
			texture_rect.texture = texture_empty
			
		h_box.add_child(texture_rect)
