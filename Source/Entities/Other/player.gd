extends CharacterBody2D

@export var speed: float = 700
@export var camera_speed: float = 4
var camera_direction: Vector2 = Vector2.ZERO
var camera_offset_limit: float = 0.5
var pick_up_check : bool = false
var nearest_weapon = null

var weapon_container: Array[Node] = []
var current_weapon: Node = null
var selected_weapon: int = 0
@export var weapon_container_capacity = 3

signal UI_WeaponChanged(weapon)

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		$PlayerSprites.play()
	else:
		$PlayerSprites.stop()
	
	velocity = input_dir * speed
	move_and_slide()
	
	# Obrót w stronę kursora
	var direction = get_global_mouse_position() - global_position
	rotation = direction.angle() + 0.5*PI
	
	#if !weapon_container.is_empty():
		
		
	
	
	# Strzały
	#~~Kleks dodalem mozliwosc przytrzymania przycisku dla broni maszynowych + sygnaly do ui
	if current_weapon != null:

		if current_weapon.is_in_group("weapon-machineGuns"):
			if Input.is_action_pressed("shoot"):
				current_weapon.shoot(global_position, self)
				
			else:
				current_weapon.spread_normalize()
		if current_weapon.is_in_group("weapon-throwable"):
			if Input.is_action_pressed("shoot"):
				action_pressed_throw()
		else:
			if Input.is_action_just_pressed("shoot"):
				current_weapon.shoot(global_position, self)
			
	
		if Input.is_action_just_pressed("throw"):
			if current_weapon != null:
				action_pressed_throw()
			else:
				print("Nie masz broni do wyrzucenia")
			
	
	
	if  Input.is_action_pressed("control_camera"):
		camera_direction=lerp(camera_direction,(direction-$Camera.get_offset())*camera_offset_limit*$Camera.zoom,camera_speed*delta)
		$Camera.set_offset(camera_direction)
	else:
		camera_direction=lerp(camera_direction,Vector2.ZERO,camera_speed*delta)
		$Camera.set_offset(camera_direction)
		
	if pick_up_check:
		if Input.is_action_just_pressed("pick_up"):
			if nearest_weapon != null:
				nearest_weapon.pick_up(self)

func action_pressed_throw():
	current_weapon.throw(global_position, velocity)
	current_weapon = null
	emit_signal("UI_WeaponChanged", current_weapon)	
		
func get_player_occupied():
	if current_weapon != null:
		pick_up_check = false
		return true
	else:
		return false
	
