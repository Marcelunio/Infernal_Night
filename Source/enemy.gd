extends CharacterBody2D

@export var speed: float = 300.0
@export var start_delay: float = 1.0
@export var target_path: NodePath

var wait_timer: float = 0.0
var active: bool = false
var target: Node2D
var applied_velocity: Vector2 = Vector2.ZERO

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var sprite: Node2D = $EnemySprite  

func _ready():
	if target_path and has_node(target_path):
		target = get_node(target_path)
	else:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]

	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.max_speed = speed
	navigation_agent.avoidance_enabled = true
	navigation_agent.velocity_computed.connect(_on_navigation_agent_velocity_computed)

func _physics_process(delta: float) -> void:
	if not active:
		wait_timer += delta
		if wait_timer >= start_delay:
			active = true
		return

	if not is_instance_valid(target):
		return

	navigation_agent.target_position = target.global_position

	var next_point: Vector2 = navigation_agent.get_next_path_position()
	var direction := (next_point - global_position)

	if direction.length() < 5.0:
		direction = target.global_position - global_position

	if direction.length() > 0.1:
		direction = direction.normalized() * speed
	else:
		direction = Vector2.ZERO

	if direction.length() > 0.1 and sprite:
		sprite.rotation = direction.angle() + deg_to_rad(90)


	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(direction)
	else:
		applied_velocity = direction

	velocity = applied_velocity
	move_and_slide()

func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	applied_velocity = safe_velocity
