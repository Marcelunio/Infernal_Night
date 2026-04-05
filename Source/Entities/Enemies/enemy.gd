extends CharacterBody2D
class_name Enemy

@export var max_hp: int = 360
@export var speed := 260.0
@export var turn_speed := 8.0
@export var shoot_cooldown := 1.5

# STOŻEK
@export var vision_angle := 0.4
@export var vision_distance := 800.0
@export var vision_rays := 9
@export var debug_mode := false

# STRAFE
@export var strafe_speed := 140.0
@export var strafe_switch_time := 0.8
@export var strafe_blend_time := 0.25

# FORMACJA
@export var formation_radius := 80.0
@export var formation_refresh_time := 3.0

# =========================
# STATE MACHINE
# =========================
enum State { APPROACH, STRAFE }

var state: State = State.APPROACH

# =========================
# ZMIENNE 
# =========================
var hp: int
var player: Node2D = null
var dead := false
var frozen := false

# ruch
var move_dir := Vector2.RIGHT
var face_dir := Vector2.RIGHT

# strzelanie
var is_shooting := false
var shoot_timer := 0.0

# strafe
var strafe_dir := 1
var strafe_timer := 0.0
var strafe_blend := 0.0

# formacja
var formation_offset := Vector2.ZERO
var formation_refresh_timer := 0.0

# stuck detection
var stuck_timer := 0.0
const STUCK_TIMEOUT := 1.5

# debug
var debug_rays: Array = []

# =========================
# NODY
# =========================
@onready var agent: NavigationAgent2D = $EnemyNavigation

signal enemy_died

# =========================
# INIT
# =========================
func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	move_dir = Vector2.RIGHT.rotated(randf() * TAU)
	face_dir = move_dir
	strafe_dir = 1 if randf() > 0.5 else -1
	_find_player_async()

func _find_player_async() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("player")
		await get_tree().process_frame
	await get_tree().process_frame
	_randomize_formation_offset()

# =========================
# GŁÓWNA PĘTLA
# =========================
func _physics_process(delta: float) -> void:
	if dead or frozen or player == null:
		return

	_update_shoot_timer(delta)
	_update_state()
	_update_formation(delta)
	_process_state(delta)
	_update_rotation(delta)

# =========================
# STRZELANIE
# =========================
func _update_shoot_timer(delta: float) -> void:
	shoot_timer -= delta
	if shoot_timer <= 0.0 and can_shoot() and not is_shooting:
		shoot()
		shoot_timer = shoot_cooldown

# =========================
# AKTUALIZACJA STANU
# =========================
func _update_state() -> void:
	match state:
		State.APPROACH:
			if is_shooting:
				state = State.STRAFE
		State.STRAFE:
			if not is_shooting:
				state = State.APPROACH

# =========================
# FORMACJA
# =========================
func _randomize_formation_offset() -> void:
	if player == null:
		return

	var map := agent.get_navigation_map()

	for _i in 8:
		var angle := randf() * TAU
		var desired: Vector2 = Vector2(cos(angle), sin(angle)) * formation_radius
		var target: Vector2 = player.global_position + desired
		var closest: Vector2 = NavigationServer2D.map_get_closest_point(map, target)

		if closest.distance_to(target) < 32.0:
			formation_offset = closest - player.global_position
			return

	formation_offset = Vector2.ZERO

func _update_formation(delta: float) -> void:
	if state == State.STRAFE:
		return
	var dist := global_position.distance_to(player.global_position)
	if dist > formation_radius * 1.5:
		formation_refresh_timer -= delta
		if formation_refresh_timer <= 0.0:
			_randomize_formation_offset()
			formation_refresh_timer = formation_refresh_time + randf_range(-0.5, 0.5)

# =========================
# PRZETWARZANIE STANU
# =========================
func _process_state(delta: float) -> void:
	match state:
		State.APPROACH:
			strafe_blend = move_toward(strafe_blend, 0.0, delta / strafe_blend_time)
			_do_approach(delta)
		State.STRAFE:
			strafe_blend = move_toward(strafe_blend, 1.0, delta / strafe_blend_time)
			if strafe_blend > 0.99:
				_do_strafe(delta)
			else:
				_do_blend_to_strafe(delta)

# =========================
# APPROACH
# =========================
func _do_approach(delta: float) -> void:
	var dist := global_position.distance_to(player.global_position)
	if dist < formation_radius * 0.8 and can_see_player_cone():
		face_dir = (player.global_position - global_position).normalized()
		velocity = Vector2.ZERO
		stuck_timer = 0.0
		move_and_slide()
		return

	agent.target_position = player.global_position + formation_offset

	if agent.is_navigation_finished():
		face_dir = (player.global_position - global_position).normalized()
		velocity = Vector2.ZERO
		stuck_timer += delta
		if stuck_timer > STUCK_TIMEOUT:
			stuck_timer = 0.0
			_randomize_formation_offset()

		move_and_slide()
		return

	stuck_timer = 0.0

	var next_point := agent.get_next_path_position()
	var desired_dir := (next_point - global_position).normalized()
	move_dir = move_dir.slerp(desired_dir, turn_speed * delta).normalized()
	face_dir = move_dir

	velocity = move_dir * speed
	move_and_slide()

# =========================
# STRAFE
# =========================
func _do_strafe(delta: float) -> void:
	strafe_timer -= delta
	if strafe_timer <= 0.0:
		strafe_dir *= -1
		strafe_timer = strafe_switch_time + randf_range(-0.2, 0.2)

	var to_player := (player.global_position - global_position).normalized()
	face_dir = to_player

	var dist := global_position.distance_to(player.global_position)
	if dist < formation_radius * 0.8:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var perpendicular := Vector2(-to_player.y, to_player.x) * strafe_dir
	velocity = perpendicular * strafe_speed
	move_and_slide()

# =========================
# BLEND DO STRAFE
# =========================
func _do_blend_to_strafe(delta: float) -> void:
	var nav_velocity := Vector2.ZERO
	agent.target_position = player.global_position + formation_offset
	if not agent.is_navigation_finished():
		var next_point := agent.get_next_path_position()
		var desired_dir := (next_point - global_position).normalized()
		move_dir = move_dir.slerp(desired_dir, turn_speed * delta).normalized()
		nav_velocity = move_dir * speed

	var to_player := (player.global_position - global_position).normalized()
	var perpendicular := Vector2(-to_player.y, to_player.x) * strafe_dir
	var strafe_velocity := perpendicular * strafe_speed

	velocity = nav_velocity.lerp(strafe_velocity, strafe_blend)
	move_and_slide()

	face_dir = move_dir.slerp(to_player, strafe_blend).normalized()

# =========================
# ROTACJA 
# =========================
func _update_rotation(delta: float) -> void:
	rotation = lerp_angle(rotation, face_dir.angle(), turn_speed * delta)

# =========================
# DEBUG RYSOWANIE
# =========================
func _draw() -> void:
	if not debug_mode:
		return
	for ray in debug_rays:
		draw_line(
			to_local(ray["from"]),
			to_local(ray["to"]),
			ray["color"],
			2.0
		)

# =========================
# STOŻEK (SWEEP)
# =========================
func can_see_player_cone() -> bool:
	if player == null:
		return false

	if global_position.distance_squared_to(player.global_position) > vision_distance * vision_distance:
		if debug_mode:
			debug_rays.clear()
			queue_redraw()
		return false

	var space_state := get_world_2d().direct_space_state
	var base_angle := rotation
	var hit_player := false

	if debug_mode:
		debug_rays.clear()

	var query := PhysicsRayQueryParameters2D.new()
	query.exclude = [self]
	query.collision_mask = 0xFFFFFFFF & ~(2 | 4)

	for i in vision_rays:
		var t := float(i) / (vision_rays - 1)
		var angle_offset := lerpf(-vision_angle, vision_angle, t)
		var dir := Vector2.RIGHT.rotated(base_angle + angle_offset)

		query.from = global_position
		query.to = global_position + dir * vision_distance

		var result := space_state.intersect_ray(query)

		if result.is_empty():
			if debug_mode:
				debug_rays.append({"from": global_position, "to": query.to, "color": Color.RED})
			continue

		var collider = result["collider"]
		if collider == player:
			hit_player = true
			if not debug_mode:
				return true

		if debug_mode:
			debug_rays.append({
				"from": global_position,
				"to": result["position"],
				"color": Color.GREEN if collider == player else Color.YELLOW
			})

	if debug_mode:
		queue_redraw()

	return hit_player

# =========================
# STRZAŁ
# =========================
func can_shoot() -> bool:
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
	if player == null:
		return
	is_shooting = true
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		is_shooting = false

# =========================
# DAMAGE
# =========================
func take_damage(amount: int, _hit_pause := 0.0) -> void:
	if dead:
		return
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	dead = true
	set_physics_process(false)
	emit_signal("enemy_died")
	player.enemy_deaths += 1
	queue_free()
