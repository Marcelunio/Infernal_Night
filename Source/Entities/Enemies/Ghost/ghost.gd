# The skorpogest
extends Enemy
class_name Ghost

# =========================
# ZMIENNE
# =========================
@export var projectile_scene: PackedScene
@export var shoot_cooldown := 2

# =========================
# FUNKCJE WBUDOWANE
# =========================
func _ready() -> void:
	super._ready()
	_start_shooting()

# =========================
# STRZELANIE LOOP
# =========================
func _start_shooting() -> void:
	while not dead:
		await get_tree().create_timer(shoot_cooldown).timeout
		_shoot()

# =========================
# STRZAŁ POTRÓJNY
# =========================
func _shoot() -> void:
	if not player:
		return
	
	var dir: Vector2 = (player.global_position - global_position).normalized()

	for i in 3:
		_spawn_bullet(dir)
		await get_tree().create_timer(0.15).timeout

# =========================
# SPAWN POCISKU
# =========================
func _spawn_bullet(dir: Vector2) -> void:
	var bullet = projectile_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = global_position
	bullet.direction = dir
	
	bullet.global_position = global_position + dir * 20.0
# =========================
# DAMAGE
# =========================
func take_damage(amount: int, _hit_pause := 0.15) -> void:
	super.take_damage(amount)
