extends CharacterBody2D

@export var speed: float = 700
var current_weapon: Node = null

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
	
	velocity = input_dir * speed
	move_and_slide()
	
	# Obrót w stronę kursora
	var direction = get_global_mouse_position() - global_position
	rotation = direction.angle() + deg_to_rad(90)
	
	# Strzały
	if Input.is_action_just_pressed("shoot"):
		if current_weapon != null:
			print("Bang!", current_weapon.weapon_name)
			current_weapon.shoot(global_position, self)
		else:
			print("Nie masz broni")
	
	if Input.is_action_just_pressed("throw"):
		if current_weapon != null:
			current_weapon.throw(global_position, velocity.length())
			current_weapon = null
		else:
			print("Nie masz broni do wyrzucenia")
			
func get_player_occupied():
	if current_weapon != null:
		return true
	else:
		return false
