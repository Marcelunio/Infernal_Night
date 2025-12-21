@abstract
class_name Enemy
extends CharacterBody2D

@export var enemy_name: String = ""
@export var max_hp: int
@export var speed: float
@export var start_delay: float
@export var default_stun_time: float
@export var can_be_stunned: bool = true
@export var rotation_speed: float

#ghost
@export var phasing: bool = false

#skelly
@export var post_mortem: bool = false
@export var post_mortem_max_hp: float
@export var post_mortem_down: bool = false

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

@abstract
func __find_target() -> Node2D

@abstract
func __die() -> void

func __on_damage_taken(_amount: int) -> void:
	pass

func __while_stunned(_delta):
	pass
	
func __ready() -> void:
	pass

func __on_physics_process(_delta: float) -> void:
	pass
	
func __post_mortem() -> void:
	pass

func _ready() -> void:
	hp = max_hp
	
	target = __find_target()
			
	if navigation_agent:
		navigation_agent.path_desired_distance = 4.0
		navigation_agent.target_desired_distance = 4.0
		navigation_agent.max_speed = speed
		navigation_agent.avoidance_enabled = true
		navigation_agent.velocity_computed.connect(_on_navigation_agent_velocity_computed)
		
	__ready()
	
func _physics_process(delta: float) -> void:
	
	__on_physics_process(delta)
	
	if post_mortem_down:
		return
	
	if stunned:
		stun_timer -= delta
		__while_stunned(delta)
		if stun_timer <= 0.0:
			stunned = false
		else:
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
	#else:
		#dir = target.global_position - global_position

	if dir.length() > 0.1:
		dir = dir.normalized()
		applied_velocity = dir * speed
		var target_rotation = dir.angle() + 0.5 * PI
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	else:
		applied_velocity = Vector2.ZERO

	velocity = applied_velocity
	move_and_slide()

func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	applied_velocity = safe_velocity

func take_damage(amount: int, stun_dur: float = -1.0) -> void:
	if stun_dur <= 0.0:
		stun_dur = default_stun_time
	
	__on_damage_taken(amount)
	hp -= amount
	if hp <= 0:
		_die()
		return

	if can_be_stunned:
		stunned = true
		stun_timer = stun_dur
		applied_velocity = Vector2.ZERO
		velocity = Vector2.ZERO

func _die() -> void:
	if post_mortem:
		__post_mortem()
	else:
		__die()
