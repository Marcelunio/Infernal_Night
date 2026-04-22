extends Control

var boss: Node;
@onready var health_bar:Node=$SubViewport/TextureProgressBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss=get_tree().get_first_node_in_group("enemy")
	boss.connect("BossDamaged",update_health_bar)
	health_bar.max_value=boss.max_hp;
	health_bar.value=health_bar.max_value

func update_health_bar(amount:int):
	health_bar.value-=amount
