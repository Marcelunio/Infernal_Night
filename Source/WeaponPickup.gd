extends RigidBody2D

@export var weapon_name: String = "Pistol"
@export var throw_force: float = 1000
var player_velocity_to_throw_force:float =0.6
var is_picked_up: bool = false

#do fizyki rzucania bronia
var is_thrown: bool = false

#fizyka strzalu
var bullet_speed: float = 1500

func _ready():
	print("Ready wywołane!")
	var area = get_node("Area2D")
	print("Area znalezione:", area)
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	print("Sygnał podłączony!")
	
func _physics_process(delta):
	if is_thrown and linear_velocity.length() > 0:
		var velocity_dir = linear_velocity.normalized()
		linear_velocity -= velocity_dir * 250 * delta  #Mocne hamowanie!
		rotation += 0.01 * linear_velocity.length() * delta
		
		# Zatrzymaj całkowicie gdy wolno jedzie
		if linear_velocity.length() < 80:
			linear_velocity = Vector2.ZERO
			angular_velocity = 0  # Zatrzymaj obrót też
			is_thrown = false
	

func _on_body_entered(body):
	if is_picked_up or is_thrown:
		return
		
	if body.is_in_group("player"):
		if body.get_player_occupied():
			return
			
		is_picked_up = true
		print("Podniosłeś:", weapon_name)
		
		#freeze = true #wylacza fizyke
		
		# Ukryj broń ale nie usuwaj jej
		hide()
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		# Przenieś broń jako dziecko gracza
		var parent = get_parent()
		parent.call_deferred("remove_child", self)
		body.call_deferred("add_child", self)
		
		# Ustaw pozycję lokalną na (0,0)
		position = Vector2.ZERO
		
		# Ustaw jako aktualną broń
		body.current_weapon = self

func throw(spawn_pos: Vector2, velocity_player):
	print("Broń wyrzucona:", weapon_name)
	is_picked_up = false
	
	# Usuń z gracza i dodaj z powrotem do sceny
	var player = get_parent()
	player.remove_child(self)
	player.get_parent().add_child(self)
	
	# Ustaw pozycję
	global_position = spawn_pos
	
	# Pokaż z powrotem
	show()
	
	var throw_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))
	
	#freeze = false #wlacza fizyke
	is_thrown = true
	apply_impulse(throw_direction * throw_force + velocity_player*player_velocity_to_throw_force)
func shoot(spawn_pos: Vector2, player):
	print("DEBUG - oddano strzal")
	var bullet = preload("res://Scenes/bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = spawn_pos
	
	var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))
	bullet.direction = shoot_direction
	bullet.shooter = player
	#apply_impulse(shoot_direction * bullet_speed)

	
