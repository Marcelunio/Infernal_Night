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
var player: Node2D
var move_dir := Vector2.RIGHT
var dead := false


# =========================
# FUNKCJE WBUDOWANE
# =========================

func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("the whatest")
		set_physics_process(false)
		return

	move_dir = Vector2.RIGHT.rotated(randf() * TAU)


func _physics_process(delta: float) -> void:
	if dead:
		return

	agent.target_position = player.global_position

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_point := agent.get_next_path_position()
	var desired_dir := (next_point - global_position).normalized()

	move_dir = move_dir.slerp(desired_dir, turn_speed * delta).normalized()
	velocity = move_dir * speed

	move_and_slide()

	rotation = move_dir.angle()


# =========================
# LOGIKA GRY
# =========================

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
