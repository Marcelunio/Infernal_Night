extends EnemyProjectile
class_name GhostProjectile2

@export var turn_rate := 1.2

var target: Node2D = null
var _room_bounds: Rect2

func _ready() -> void:
	super._ready()
	collision_layer = 0
	collision_mask = 0

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		var to_target := (target.global_position - global_position).normalized()
		direction = direction.slerp(to_target, turn_rate * delta).normalized()

	rotation = direction.angle() + PI / 2

	var next_pos := global_position + direction * speed * delta

	if _room_bounds != Rect2() and not _room_bounds.has_point(next_pos):
		queue_free()
		return

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, next_pos)
	query.exclude = [self]
	query.collision_mask = 1
	var result := space_state.intersect_ray(query)
	if not result.is_empty() and result["collider"].is_in_group("player"):
		if result["collider"].has_method("take_damage"):
			result["collider"].take_damage(damage)
		queue_free()
		return

	global_position = next_pos
