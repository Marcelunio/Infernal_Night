extends Area2D

@export var texture: Texture2D
@export var amount_of_healing: int
@export var type: String
@export var coin_value: int

func _ready() -> void:
	$Sprite2D.texture = texture
	
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if type == "heart":
		body.heal(amount_of_healing, self)
	elif type == "coin":
		body.get_node("InventoryMenager").coins += coin_value
		body.get_node("InventoryMenager").emit_signal("UI_InventoryCoinChanged")
		self.queue_free()
