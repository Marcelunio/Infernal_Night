# enemy_projectile.gd
extends CharacterBody2D
class_name EnemyProjectile

@export var speed := 600.0
@export var damage := 1
@export var lifetime := 3.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(_delta: float) -> void:
	rotation = direction.angle() + PI / 2
	velocity = direction * speed
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body:
			if body.is_in_group("player"):
				if body.has_method("take_damage"):
					body.take_damage(damage)
				queue_free()
				return
			if body.is_in_group("enemy"):
				return
			queue_free()
			return
