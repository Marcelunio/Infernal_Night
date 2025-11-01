extends Area2D

var direction: Vector2 = Vector2.RIGHT
var bullet_speed: float = 1500
var shooter = null

@export var damage: int = 1

func _ready():
	add_to_group("projectiles")
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	position += direction * bullet_speed * delta
	rotation = direction.angle() - PI / 2

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, 0.12)   
		elif body.has_method("_take_damage"):
			body._take_damage(damage, 0.12)
	queue_free()

func get_damage() -> int:
	return damage
