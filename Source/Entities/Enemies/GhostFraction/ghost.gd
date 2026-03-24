# The skorpogest
# Znane bugi: 0
extends Enemy
class_name Ghost

# =========================
# ZMIENNE
# =========================
# --- Teleport config ---
@export var teleport_cooldown := 4.0
@export var invisible_time := 0.2

# --- Spawn safety ---
@export var spawn_attempts := 8

# --- Referencje ---
@onready var sprite: Sprite2D = $EnemySprite
@onready var nav_map := get_world_2d().navigation_map

# --- Stan ---
var is_phased := false
var teleport_target: Vector2

# =========================
# FUNKCJE WBUDOWANE
# =========================
func _ready() -> void:
	super._ready()
	_start_teleport_loop()

# =========================
# TELEPORT LOOP
# =========================
func _start_teleport_loop() -> void:
	while not dead:
		await get_tree().create_timer(teleport_cooldown).timeout
		await _teleport()

# =========================
# TELEPORT
# =========================
func _teleport() -> void:
	is_phased = true
	set_collision_enabled(false)

	# krótka niewidzialność (opcjonalne)
	sprite.visible = false
	await get_tree().create_timer(invisible_time).timeout

	# wybór miejsca
	teleport_target = _get_random_point_in_room()

	# teleport
	global_position = teleport_target

	# powrót
	sprite.visible = true
	set_collision_enabled(true)
	is_phased = false

# =========================
# POSITIONING
# =========================
func _get_random_point_in_room() -> Vector2:
	if not player:
		return global_position
	
	for i in spawn_attempts:
		var angle := randf() * TAU
		var distance := randf_range(100.0, 300.0)
		var candidate := player.global_position + Vector2.RIGHT.rotated(angle) * distance
		
		# dopasowanie do navmesha (czyli "gdzie można chodzić")
		var safe_point: Vector2 = NavigationServer2D.map_get_closest_point(nav_map, candidate)
		
		# sprawdzamy czy nie wskoczył gdzieś daleko (np. inny pokój)
		if safe_point.distance_to(candidate) < 64.0:
			return safe_point
	
	return global_position

# =========================
# DAMAGE
# =========================
func take_damage(amount: int, _hit_pause := 0.0) -> void:
	if is_phased:
		return
	super.take_damage(amount)
