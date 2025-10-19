extends RigidBody2D

@export var weapon_name: String = "Shotgun"
@export var throw_force: float = 800
var player_velocity_to_throw_force:float = 0.6
var is_picked_up: bool = false

#do fizyki rzucania bronia
var is_thrown: bool = false

#fizyka strzalu
var bullet_speed: float = 1500

#~~Kleks 19.10.2025
#Timer strzalu
var timer: Timer

#~~Kleks 19.10.2025
#fizyka strzelanie z shotguna
var spread_angle = 3.75
var bullet_count = 6

func _ready():
	print("Ready wywołane!")
	var area = get_node("WeaponArea-shotgun")
	print("Area znalezione:", area)
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	print("Sygnał podłączony!")
	
	#~~Kleks 19.10.2025
	#Timer strzalu
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.83
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
		# Przenieś broń jako dziecko gracza
		var parent = get_parent()
		parent.call_deferred("remove_child", self)
		body.call_deferred("add_child", self)

		position = Vector2.ZERO

		body.current_weapon = self

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
		
func shoot(spawn_pos: Vector2, player):
	
	#~~Kleks 19.10.2025 
	#dodaje timer zeby nie bylo mozna strzelac z shotguna jak z akacza xD + fizyka shotguna
	if !(timer.is_stopped()):
		return
		
	timer.start()
	
	print("DEBUG - oddano strzal")
	for i in range(bullet_count):
		
		var bullet = preload("res://Scenes/bullet.tscn").instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = spawn_pos
		
		var angle_offset = (i - bullet_count / 2.0) * spread_angle
	
		var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
		bullet.direction = shoot_direction
		bullet.shooter = player
	
	
	#apply_impulse(shoot_direction * bullet_speed)
