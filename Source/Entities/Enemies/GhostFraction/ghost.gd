# The skorpogest
# somewhat finished (trzeba zrobic zeby gracz umieral)
extends Enemy
class_name Ghost

# =========================
# ZMIENNE
# =========================

# --- Fade config ---
@export var fade_out_time := 0.5
@export var invisible_time := 2.5
@export var fade_in_time := 0.5

# --- Cooldown ---
@export var fade_cooldown := 4.0

# --- Spawn safety ---
@export var spawn_attempts := 8

# --- Zachowanie ghosta ---
@export var orbit_distance := 180.0
@export var side_drift_speed := 0.6

# --- Referencje ---
@onready var sprite: Sprite2D = $EnemySprite
@onready var nav_map := get_world_2d().navigation_map

# --- Stan ---
var is_phased := false
var fade_target_position: Vector2

# =========================
# FUNKCJE
# =========================

func _ready() -> void:
	super._ready()
	_start_fade_cycle()

# =========================
# LOW TAPER FADE
# =========================

func _start_fade_cycle() -> void:
	while not dead:
		await get_tree().create_timer(fade_cooldown).timeout
		await _fade_out()
		await get_tree().create_timer(invisible_time).timeout
		await _fade_in()

func _fade_out() -> void:
	is_phased = true
	set_collision_enabled(false)

	var t := 0.0
	while t < fade_out_time:
		t += get_process_delta_time()

		if player:
			var to_player := (player.global_position - global_position).normalized()
			var side_dir := Vector2(-to_player.y, to_player.x)
			velocity = side_dir * speed * side_drift_speed
			move_and_slide()

		sprite.modulate.a = lerp(1.0, 0.0, t / fade_out_time)
		await get_tree().process_frame

	velocity = Vector2.ZERO
	fade_target_position = _get_safe_spawn_point()

func _fade_in() -> void:
	global_position = fade_target_position

	var t := 0.0
	while t < fade_in_time:
		t += get_process_delta_time()
		sprite.modulate.a = lerp(0.0, 1.0, t / fade_in_time)
		await get_tree().process_frame

	is_phased = false
	set_collision_enabled(true)

# =========================
# POSITIONING
# =========================

func _get_safe_spawn_point() -> Vector2:
	if not player:
		return global_position

	for i in spawn_attempts:
		var angle := randf() * TAU
		var offset := Vector2.RIGHT.rotated(angle) * orbit_distance
		var candidate := player.global_position + offset
		var safe_point := NavigationServer2D.map_get_closest_point(nav_map, candidate)

		if safe_point.distance_to(candidate) < 32.0:
			return safe_point

	return global_position

# =========================
# DAMAGE
# =========================

func take_damage(amount: int, _hit_pause := 0.0) -> void:
	if is_phased:
		return
	super.take_damage(amount)
