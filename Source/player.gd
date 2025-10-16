extends CharacterBody2D

@export var speed: float = 700
@export var camera_speed: float =4
var current_weapon: Node = null
var camera_direction: Vector2 = Vector2.ZERO
var camera_offset_limit: float = 0.5

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
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	velocity = input_dir * speed
	move_and_slide()
	
	# Obrót w stronę kursora
	var direction = get_global_mouse_position() - global_position
	rotation = direction.angle() + 0.5*PI
	
	# Strzały
	if Input.is_action_just_pressed("shoot"):
		if current_weapon != null:
			print("Bang!", current_weapon.weapon_name)
			current_weapon.shoot(global_position, self)
		else:
			print("Nie masz broni")
	
	if Input.is_action_just_pressed("throw"):
		if current_weapon != null:
			current_weapon.throw(global_position, velocity)
			current_weapon = null
		else:
			print("Nie masz broni do wyrzucenia")
			
	
	
	if  Input.is_action_pressed("control_camera"):
		camera_direction=lerp(camera_direction,(direction-$Camera2D.get_offset())*camera_offset_limit*$Camera2D.zoom,camera_speed*delta)
		$Camera2D.set_offset(camera_direction)
	else:
		camera_direction=lerp(camera_direction,Vector2.ZERO,camera_speed*delta)
		$Camera2D.set_offset(camera_direction)
func get_player_occupied():
	if current_weapon != null:
		return true
	else:
		return false
