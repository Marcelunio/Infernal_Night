# sniper_ghost.gd
extends Enemy
class_name SniperGhost

@export var projectile_scene: PackedScene
@export var bullet_speed := 800.0
@export var bullet_turn_rate := 1.2

var _room_bounds: Rect2

func _ready() -> void:
	super._ready()
	# Pobierz bounds pokoju w którym jest sniper
	await get_tree().process_frame
	var rooms := get_tree().get_nodes_in_group("room_area")
	for room in rooms:
		var shape := room.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape and shape.shape is RectangleShape2D:
			var rect := shape.shape as RectangleShape2D
			var bounds := Rect2(shape.global_position - rect.size / 2, rect.size)
			if bounds.has_point(global_position):
				_room_bounds = bounds
				break

func _do_approach(_delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if player:
		face_dir = (player.global_position - global_position).normalized()

func _do_strafe(_delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if player:
		face_dir = (player.global_position - global_position).normalized()

func _do_blend_to_strafe(_delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if player:
		face_dir = (player.global_position - global_position).normalized()

func can_shoot() -> bool:
	if player == null:
		return false
	return global_position.distance_squared_to(player.global_position) < vision_distance * vision_distance

func shoot() -> void:
	if player == null or is_shooting:
		return
	is_shooting = true
	var dir := (player.global_position - global_position).normalized()
	_spawn_bullet(dir)
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(self):
		is_shooting = false

func _spawn_bullet(dir: Vector2) -> void:
	if not projectile_scene:
		push_error("SniperGhost: brak projectile_scene!")
		return
	var bullet := projectile_scene.instantiate() as GhostProjectile2
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + dir * 24.0
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.turn_rate = bullet_turn_rate
	bullet.target = player
	bullet._room_bounds = _room_bounds
