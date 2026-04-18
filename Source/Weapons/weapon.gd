#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
@abstract
class_name Weapon
extends RigidBody2D
@export var offset: Vector2
@export var weapon_name: String = ""
@onready var sprite_node = $"WeaponSprite"
@export var throw_force: float
@export var weapon_delay: float
@export var weapon_damage: float
@export var sprite: Texture2D

var outline:Material =load("res://Assets/Weapons/weapon_outline.tres");
const PLAYER_VELOCITY_TO_THROW_FORCE: float =0.6
var is_picked_up: bool = false
var is_thrown: bool = false

var timer: Timer

#ammo
@export var weapon_ammo_type: String = ""
@export var max_ammo: int
@onready var current_ammo: int = max_ammo
@export var reload_time: float 

func _ready():
	call_deferred("_connect_signals")
	var area = get_node_or_null("WeaponArea")
	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("body_exited", Callable(self, "_on_body_exited"))
	else:
		push_error("Brak WeaponArea w " + weapon_name + "! Nie będzie można podnieść.")
	
	sprite_node.texture = add_padding(sprite,5)
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
	apply_impulse(throw_direction * throw_force + velocity_player* PLAYER_VELOCITY_TO_THROW_FORCE)

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

func add_padding(texture:Texture2D,padding:int):
	var original_image=texture.get_image()
	if(original_image.is_compressed()):
		original_image.decompress()
	if original_image.get_format() !=Image.FORMAT_RGBA8:
		original_image.convert(Image.FORMAT_RGBA8)
	
	var new_width=original_image.get_width()+padding*2
	var new_height =original_image.get_height()+padding*2
	
	var padded_image=Image.create(new_width,new_height,false,Image.FORMAT_RGBA8)
	padded_image.fill(Color(0,0,0,0))
	padded_image.blit_rect(
		original_image,
		Rect2(0,0,original_image.get_width(),original_image.get_height()),
		Vector2(padding,padding)
		)
	return ImageTexture.create_from_image(padded_image)
	
func _connect_signals():
	var player = get_tree().get_first_node_in_group("player")
	var inventory = player.get_node("InventoryMenager")
	inventory.UI_NearestItemChanged.connect(_closest_to_player)
	
func _closest_to_player(item, closest):
	if item == self:
		if closest:
			item.get_node("WeaponSprite").material=outline;
		else:
			item.get_node("WeaponSprite").material=null;
