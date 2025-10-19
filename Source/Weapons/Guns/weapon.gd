@abstract
class_name Weapon
extends RigidBody2D

@export var weapon_name: String = "Pistol"
@onready var sprite_node = $"WeaponSprite"
var sprite: Texture2D

var throw_force: float = 1000
var player_velocity_to_throw_force: float =0.6
var is_picked_up: bool = false
var weapon_delay: float = 0.2
var is_thrown: bool = false
var max_ammo: int
var current_ammo: int 
var bullet_speed: float = 1500
var max_ammo: int = 17 #prawdziwy glock-17 tyle ma :D
var current_ammo: int = 17

var timer: Timer

func _ready():
	
	var area = get_node("WeaponArea")
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	
	sprite = sprite_node.texture
	#~~Kleks 19.10.2025
	#Timer strzalu
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = weapon_delay
	timer.one_shot = true
	
func _physics_process(delta):
	if is_thrown and linear_velocity.length() > 0:
		var velocity_dir = linear_velocity.normalized()
		linear_velocity -= velocity_dir * 250 * delta  
		rotation += 0.01 * linear_velocity.length() * delta
		
		if linear_velocity.length() < 80:
			linear_velocity = Vector2.ZERO
			angular_velocity = 0
			is_thrown = false
	

func _on_body_entered(body):
	if is_picked_up or is_thrown:
		return
		
	if body.name == "Player":
		if body.get_player_occupied():
			return
			
		is_picked_up = true
		print("Podniosłeś: ", weapon_name)
		
		# Ukryj broń ale nie usuwaj jej
		hide()
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)

		var parent = get_parent()
		parent.call_deferred("remove_child", self)
		body.call_deferred("add_child", self)

		position = Vector2.ZERO
		
		body.current_weapon = self
		body.UI_weapon_signal()

func throw(spawn_pos: Vector2, velocity_player):
	print("Broń wyrzucona: ", weapon_name)
	is_picked_up = false
	
	# Usuwa z gracza i dodaj z powrotem do sceny
	var player = get_parent()
	player.remove_child(self)
	player.get_parent().add_child(self)
	
	global_position = spawn_pos
	
	show()
	
	var throw_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))

	is_thrown = true
	apply_impulse(throw_direction * throw_force + velocity_player*player_velocity_to_throw_force)

@abstract
func __shoot(spawn_pos: Vector2, player)->void
	

func shoot(spawn_pos: Vector2, player):
	
	#~~Kleks 19.10.2025 
	#dodaje timer zeby nie bylo mozna strzelac z pistoletu jak z akacza xD + ammo
	if !(timer.is_stopped()):
		return
		
	if current_ammo <= 0:
		print("dzwiek pustego magazynka XD")
		return
		
	timer.start()
	__shoot(spawn_pos,player)
	
	current_ammo -= 1
