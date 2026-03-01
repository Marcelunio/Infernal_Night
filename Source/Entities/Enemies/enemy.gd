# the skorpogest
# Znane bugi: 0
extends CharacterBody2D
class_name Enemy

# =========================
# ZMIENNE
# =========================
@export var max_hp: int = 120
@export var speed := 260.0
@export var turn_speed := 8.0

@onready var agent: NavigationAgent2D = $EnemyNavigation

var hp: int
var player: Node2D = null
var move_dir: Vector2 = Vector2.RIGHT
var dead := false
<<<<<<< HEAD
var frozen := false
=======

>>>>>>> 6b032a27bbdb579a0ded68bcbc75c3dac411f84f
var _saved_collision_layer: int
var _saved_collision_mask: int

# =========================
# READY
# =========================
func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	move_dir = Vector2.RIGHT.rotated(randf() * TAU)

	_find_player_async()

func _find_player_async() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("player")
		await get_tree().process_frame

# =========================
# PHYSICS
# =========================
func _physics_process(delta: float) -> void:
	if dead or frozen:
		return

	if player == null:
		return

	agent.target_position = player.global_position

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_point: Vector2 = agent.get_next_path_position()
	var desired_dir: Vector2 = (next_point - global_position).normalized()

	move_dir = move_dir.slerp(desired_dir, turn_speed * delta).normalized()
	velocity = move_dir * speed
	move_and_slide()

	rotation = move_dir.angle()

# =========================
# LOGIKA GRY
# =========================
func set_collision_enabled(value: bool) -> void:
	if value:
		collision_layer = _saved_collision_layer
		collision_mask = _saved_collision_mask
	else:
		_saved_collision_layer = collision_layer
		_saved_collision_mask = collision_mask
		collision_layer = 0
		collision_mask = 0

func take_damage(amount: int, _hit_pause := 0.0) -> void:
	if dead:
		return

	hp -= amount
	print("Enemy HP:", hp)

	if hp <= 0:
		die()

func die() -> void:
	dead = true
	set_physics_process(false)
	queue_free()
