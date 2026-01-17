# the skorpogest
extends CharacterBody2D
class_name Enemy

@export var speed := 360.0
@export var steer_force := 0.8
@export var turn_speed := 8.0

@onready var agent := $EnemyNavigation
@onready var ray_front := $RayCastFront
@onready var ray_left := $RayCastLeft
@onready var ray_right := $RayCastRight

var target: Node2D

func _ready():
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not target:
		return

	# ---- PATHFINDING ----
	agent.target_position = target.global_position
	var desired_dir := Vector2.ZERO

	if not agent.is_navigation_finished():
		desired_dir = (agent.get_next_path_position() - global_position).normalized()

	# ---- OMIJANIE PRZESZKÓD ----
	var avoid_dir := Vector2.ZERO

	if ray_front.is_colliding():
		# wymuszony skręt – nigdy STOP
		if ray_left.is_colliding() and not ray_right.is_colliding():
			avoid_dir = Vector2.RIGHT
		elif ray_right.is_colliding() and not ray_left.is_colliding():
			avoid_dir = Vector2.LEFT
		else:
			avoid_dir = Vector2.RIGHT.rotated(rotation)

	if ray_left.is_colliding():
		avoid_dir += Vector2.RIGHT
	if ray_right.is_colliding():
		avoid_dir += Vector2.LEFT

	var final_dir = desired_dir + avoid_dir * steer_force

	if final_dir.length() < 0.1:
		final_dir = desired_dir.rotated(0.5)

	final_dir = final_dir.normalized()

	# ---- RUCH ----
	velocity = final_dir * speed
	move_and_slide()

	# ---- OBRÓT W STRONĘ GRACZA(ZJEBANE TO JEST KIEDYS TO ZROBIE) ----
	var target_angle = (target.global_position - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
