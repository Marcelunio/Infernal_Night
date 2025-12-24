#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
@abstract
class_name Weapon
extends RigidBody2D

@export var weapon_name: String = ""
@onready var sprite_node = $"WeaponSprite"
@export var throw_force: float
@export var weapon_delay: float
@export var weapon_damage: float
var sprite: Texture2D


var player_velocity_to_throw_force: float =0.6
var is_picked_up: bool = false
var is_thrown: bool = false

var timer: Timer

func _ready():
	
	var area = get_node_or_null("WeaponArea")
	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("body_exited", Callable(self, "_on_body_exited"))
	else:
		push_error("Brak WeaponArea w " + weapon_name + "! Nie będzie można podnieść.")
	
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
		body.inventory.is_full(self)

func _on_body_exited(body):
	if body.name == "Player":
		body.inventory.body_exit(self)

func pick_up(body):
	is_picked_up = true
	
	if not body.inventory.add_weapon(self):
		print("Ekwipunek pelny")
		is_picked_up = false
		return
	print("Podniosłeś: ", weapon_name)
		
	# Ukryj broń ale nie usuwaj jej
	hide()
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	position = Vector2.ZERO

func throw(spawn_pos: Vector2, velocity_player):
	print("Broń wyrzucona: ", weapon_name)
	is_picked_up = false
	
	# Usuwa z gracza i dodaje z powrotem do sceny
	var player = get_tree().get_first_node_in_group("player")
	
	global_position = spawn_pos
	
	show()
	
	var throw_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))

	is_thrown = true
	apply_impulse(throw_direction * throw_force + velocity_player*player_velocity_to_throw_force)

@abstract
func __shoot(spawn_pos: Vector2, entity)->void
	

func shoot(spawn_pos: Vector2, entity)->bool:
	
	#~~Kleks 19.10.2025 
	#dodaje timer zeby nie bylo mozna strzelac z pistoletu jak z akacza xD + ammo
	if !(timer.is_stopped()):
		return false
		
	timer.start()
	__shoot(spawn_pos, entity)
	return true
