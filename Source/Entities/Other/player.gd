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
@onready var NODE_weapon_container = $WeaponContainer

signal UI_WeaponChanged(weapon)

func _unhandled_input(event: InputEvent):
	if not weapon_container.is_empty():
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("dziala scrollllllll UPPPP")
				selected_weapon = (selected_weapon + 1) % weapon_container.size()
				change_weapon(selected_weapon)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("dziala scrollllllll DOWN")
				selected_weapon = (selected_weapon - 1 + weapon_container.size()) % weapon_container.size()
				change_weapon(selected_weapon)

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
	if weapon_container.is_empty():
		return
	
	var weapon = weapon_container[selected_weapon]
	
	weapon_container.remove_at(selected_weapon)
	
	if weapon_container.is_empty():
		selected_weapon = 0
		current_weapon = null
		
	if selected_weapon >= weapon_container.size():
		selected_weapon = weapon_container.size() - 1
	
	if not weapon_container.is_empty():
		change_weapon(selected_weapon)
	else:
		emit_signal("UI_WeaponChanged", null)
	
	weapon.throw(global_position, velocity)
		
func get_player_occupied():
	if weapon_container.size() >= weapon_container_capacity:
		pick_up_check = false
		return true
	else:
		return false
		
func add_weapon_to_invetnory(weapon):
	if weapon_container.size() >= weapon_container_capacity:
		return false
		
	weapon_container.append(weapon)	
		
	current_weapon = weapon
	selected_weapon = weapon_container.size() - 1
	emit_signal("UI_WeaponChanged", current_weapon)
		
	return true
	
func change_weapon(select):
	current_weapon = weapon_container[select]
	emit_signal("UI_WeaponChanged", current_weapon)
	
	
	
