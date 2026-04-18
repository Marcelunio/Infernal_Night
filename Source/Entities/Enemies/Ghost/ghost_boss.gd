extends Enemy
class_name Boss

# =========================
# EKSPORT
# =========================
@export var projectile_scene: PackedScene
@export var bullet_speed := 500.0

# BURST
@export var burst_count := 10
@export var burst_interval := 0.1
@export var burst_cooldown := 2.0

# DASH
@export var dash_speed := 800.0
@export var dash_damage := 25
@export var dash_cooldown := 4.0
@export var dash_distance := 200.0
@export var dash_cooldown_duration := 2.0

# =========================
# STATE MACHINE BOSSA
# =========================
enum BossState { APPROACH, BURST_SHOOT, TELEPORT, DASH, DASH_COOLDOWN }

var boss_state: BossState = BossState.APPROACH

# =========================
# ZMIENNE
# =========================
var _dash_cooldown_timer := 0.0
var _dash_cooldown_shoot_timer := 0.0
var _phase2 := false
var _dash_dir := Vector2.ZERO
var _dash_damage_timer := 0.0

# =========================
# INIT
# =========================
func _ready() -> void:
	super._ready()

# =========================
# GŁÓWNA PĘTLA
# =========================
func _physics_process(delta: float) -> void:
	if dead or frozen or player == null:
		return

	_check_phase2()
	_check_contact_damage()
	_update_boss_state(delta)
	_update_rotation(delta)

# =========================
# FAZA 2
# =========================
func _check_phase2() -> void:
	if not _phase2 and hp < max_hp * 0.4:
		_phase2 = true
		_dash_cooldown_timer = dash_cooldown * 0.5

# =========================
# AKTUALIZACJA STANU
# =========================
func _update_boss_state(delta: float) -> void:
	match boss_state:
		BossState.APPROACH:
			_do_approach(delta)
			if can_shoot() and not is_shooting:
				boss_state = BossState.BURST_SHOOT
				_start_burst()

		BossState.BURST_SHOOT:
			_do_strafe(delta)
			if not is_shooting:
				boss_state = BossState.APPROACH

		BossState.TELEPORT:
			pass

		BossState.DASH:
			_do_dash(delta)

		BossState.DASH_COOLDOWN:
			_do_dash_cooldown(delta)

	if _phase2 and boss_state == BossState.APPROACH:
		_dash_cooldown_timer -= delta
		if _dash_cooldown_timer <= 0.0:
			boss_state = BossState.TELEPORT
			_start_teleport()

# =========================
# BURST SHOOT
# =========================
func _start_burst() -> void:
	is_shooting = true
	_burst_coroutine()

func _burst_coroutine() -> void:
	for i in burst_count:
		if not is_instance_valid(self) or dead:
			return
		_spawn_bullet()
		await get_tree().create_timer(burst_interval).timeout

	if is_instance_valid(self):
		is_shooting = false
		shoot_timer = burst_cooldown

func _spawn_bullet() -> void:
	if not projectile_scene or player == null:
		return
	var dir := (player.global_position - global_position).normalized()
	var bullet := projectile_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + dir * 30.0
	bullet.direction = dir
	bullet.speed = bullet_speed

# =========================
# TELEPORT (FAZA 2)
# =========================
func _start_teleport() -> void:
	var target := _get_teleport_position()
	if target == Vector2.ZERO:
		boss_state = BossState.APPROACH
		_dash_cooldown_timer = dash_cooldown
		return

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	if not is_instance_valid(self):
		return

	global_position = target
	face_dir = (player.global_position - global_position).normalized()
	rotation = face_dir.angle()

	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	await tween.finished

	if not is_instance_valid(self):
		return

	boss_state = BossState.DASH
	_dash_dir = (player.global_position - global_position).normalized()

func _get_teleport_position() -> Vector2:
	if player == null:
		return Vector2.ZERO

	var map := agent.get_navigation_map()
	var offsets: Array[Vector2] = [
		Vector2(0, -dash_distance),
		Vector2(0, dash_distance),
		Vector2(-dash_distance, 0),
		Vector2(dash_distance, 0),
	]

	for offset in offsets:
		var target: Vector2 = player.global_position + offset
		var closest: Vector2 = NavigationServer2D.map_get_closest_point(map, target)
		if closest.distance_to(target) < 32.0:
			var space_state := get_world_2d().direct_space_state
			var query := PhysicsRayQueryParameters2D.create(player.global_position, closest)
			query.exclude = [self, player]
			query.collision_mask = 0xFFFFFFFF & ~(2 | 4)
			var result := space_state.intersect_ray(query)
			if result.is_empty():
				return closest

	return Vector2.ZERO

# =========================
# DASH (FAZA 2)
# =========================
func _do_dash(delta: float) -> void:
	face_dir = _dash_dir
	velocity = _dash_dir * dash_speed
	move_and_slide()

	_dash_damage_timer -= delta
	if _dash_damage_timer <= 0.0:
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var body := collision.get_collider()
			if body and body.is_in_group("player"):
				if body.has_method("take_damage"):
					body.take_damage(dash_damage)
				_dash_damage_timer = 0.2

	var dist := global_position.distance_to(player.global_position)
	var has_wall_collision := false
	for i in get_slide_collision_count():
		var body := get_slide_collision(i).get_collider()
		if body and not body.is_in_group("player"):
			has_wall_collision = true

	if has_wall_collision or dist > dash_distance * 2.0:
		boss_state = BossState.DASH_COOLDOWN
		_dash_cooldown_shoot_timer = dash_cooldown_duration
		_dash_cooldown_timer = dash_cooldown

# =========================
# DASH COOLDOWN
# =========================
func _do_dash_cooldown(delta: float) -> void:
	_do_approach(delta)

	_dash_cooldown_shoot_timer -= delta
	if _dash_cooldown_shoot_timer <= 0.0:
		boss_state = BossState.APPROACH
		return

	if can_shoot() and not is_shooting:
		is_shooting = true
		_burst_coroutine()

# =========================
# OVERRIDES
# =========================
func can_shoot() -> bool:
	if player == null:
		return false
	if not can_see_player_cone():
		return false
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	query.collision_mask = 0xFFFFFFFF & ~(2 | 4)
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result["collider"] == player

func shoot() -> void:
	pass

func _update_shoot_timer(_delta: float) -> void:
	pass
