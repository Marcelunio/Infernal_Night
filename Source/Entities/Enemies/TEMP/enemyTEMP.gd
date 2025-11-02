extends CharacterBody2D

# --- ustawienia
@export var max_hp: int = 360
@export var speed: float = 300.0
@export var start_delay: float = 1.0
@export var default_stun_time: float = 0.12

# --- stan
var hp: int
var wait_timer: float = 0.0
var active: bool = false
var stunned: bool = false
var stun_timer: float = 0.0
var applied_velocity: Vector2 = Vector2.ZERO

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent if has_node("NavigationAgent") else null
@onready var sprite: Node2D = $Sprite2D if has_node("Sprite2D") else null

@export var target_path: NodePath
var target: Node2D = null

func _ready() -> void:
	hp = max_hp

	if target_path and has_node(target_path):
		target = get_node(target_path)
	else:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]

	if navigation_agent:
		navigation_agent.path_desired_distance = 4.0
		navigation_agent.target_desired_distance = 4.0
		navigation_agent.max_speed = speed
		navigation_agent.avoidance_enabled = true
		navigation_agent.velocity_computed.connect(_on_navigation_agent_velocity_computed)


func _physics_process(delta: float) -> void:
	if stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			stunned = false
		else:
			applied_velocity = Vector2.ZERO
			velocity = Vector2.ZERO
			move_and_slide()
			return

	if not active:
		wait_timer += delta
		if wait_timer >= start_delay:
			active = true
		return

	if not is_instance_valid(target):
		return

	var dir := Vector2.ZERO

	if navigation_agent:
		navigation_agent.target_position = target.global_position
		var next_point: Vector2 = navigation_agent.get_next_path_position()
		dir = next_point - global_position
		if dir.length() < 5.0:
			dir = target.global_position - global_position
	else:
		dir = target.global_position - global_position

	if dir.length() > 0.1:
		dir = dir.normalized()
		applied_velocity = dir * speed

		rotation = dir.angle()
	else:
		applied_velocity = Vector2.ZERO

	velocity = applied_velocity
	move_and_slide()
	
func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	applied_velocity = safe_velocity

func take_damage(amount: int, stun_dur: float = -1.0) -> void:
	if stun_dur <= 0.0:
		stun_dur = default_stun_time

	hp -= amount
	if hp <= 0:
		_die()
		return

	stunned = true
	stun_timer = stun_dur
	applied_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	move_and_slide()

func _die() -> void:
	queue_free()
