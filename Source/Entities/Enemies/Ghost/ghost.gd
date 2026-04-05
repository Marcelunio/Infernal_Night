extends Enemy
class_name Ghost

# =========================
# EKSPORT
# =========================
@export var projectile_scene: PackedScene

# TELEPORT
@export var teleport_cooldown := 4.0
@export var teleport_distance := 150.0
@export var blink_duration := 0.6

var teleport_timer := 0.0
var is_teleporting := false

# =========================
# INIT
# =========================
func _ready() -> void:
	super._ready()
	teleport_timer = teleport_cooldown

# =========================
# GŁÓWNA PĘTLA
# =========================
func _physics_process(delta: float) -> void:
	if dead or frozen or player == null:
		return

	_update_teleport(delta)
	super._physics_process(delta)

# =========================
# TELEPORT
# =========================
func _update_teleport(delta: float) -> void:
	if is_teleporting:
		return

	if can_see_player_cone():
		teleport_timer = teleport_cooldown
		return

	teleport_timer -= delta
	if teleport_timer <= 0.0:
		_start_teleport()

func _start_teleport() -> void:
	if is_teleporting:
		return

	var target := _get_teleport_position()
	if target == Vector2.ZERO:
		teleport_timer = teleport_cooldown * 0.5
		return

	is_teleporting = true
	_do_teleport(target)

func _get_teleport_position() -> Vector2:
	var player_back: Vector2 = -player.velocity.normalized()
	if player_back == Vector2.ZERO:
		player_back = (global_position - player.global_position).normalized()

	var map := agent.get_navigation_map()

	# Próbuj kilka kierunków — za plecy, boki, naprzeciwko
	var candidates: Array[Vector2] = [
		player.global_position + player_back * teleport_distance,
		player.global_position + Vector2(-player_back.y, player_back.x) * teleport_distance,
		player.global_position + Vector2(player_back.y, -player_back.x) * teleport_distance,
		player.global_position - player_back * teleport_distance,
	]

	for candidate in candidates:
		var closest: Vector2 = NavigationServer2D.map_get_closest_point(map, candidate)

		if closest.distance_to(candidate) > 32.0:
			continue

		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(player.global_position, closest)
		query.exclude = [self, player]
		query.collision_mask = 0xFFFFFFFF & ~(2 | 4)

		var result := space_state.intersect_ray(query)
		if result.is_empty():
			return closest

	return Vector2.ZERO

func _do_teleport(target: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, blink_duration * 0.5)
	await tween.finished

	if not is_instance_valid(self):
		return

	global_position = target
	face_dir = (player.global_position - global_position).normalized()
	rotation = face_dir.angle()

	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, blink_duration * 0.5)
	await tween.finished

	if not is_instance_valid(self):
		return

	teleport_timer = teleport_cooldown
	is_teleporting = false

# =========================
# STRZAŁ 
# =========================
func shoot() -> void:
	if player == null or is_shooting or is_teleporting:
		return

	is_shooting = true

	var dir := (player.global_position - global_position).normalized()
	face_dir = dir

	await _shoot_triple(dir)

	if is_instance_valid(self):
		is_shooting = false

func _shoot_triple(dir: Vector2) -> void:
	for i in 3:
		if not is_instance_valid(self):
			return
		_spawn_bullet(dir)
		await get_tree().create_timer(0.15).timeout

func _spawn_bullet(dir: Vector2) -> void:
	if not projectile_scene:
		push_error("Ghost: brak projectile_scene!")
		return

	var bullet = projectile_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + dir * 20.0
	bullet.direction = dir
