extends Area2D

@export var texture: Texture2D
@export var amount_of_healing: int

func _ready() -> void:
	$Sprite2D.texture = texture
	
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	body.heal(amount_of_healing, self)
