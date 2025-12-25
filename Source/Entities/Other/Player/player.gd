#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends CharacterBody2D

#movement
@export var speed: float = 700

#camera
@export var camera_speed: float = 4
var camera_direction: Vector2 = Vector2.ZERO
var camera_offset_limit: float = 0.5

#hp
@export var max_hp:int = 360
var hp: int

#inventory connector
@onready var inventory = $InventoryMenager

func _ready():
	hp = max_hp

func _unhandled_input(event: InputEvent):#obsługa nie obsluzonych inputow
	if not inventory.weapon_container.is_empty():
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("dziala scrollllllll UPPPP")
				inventory.next_weapon()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("dziala scrollllllll DOWN")
				inventory.previous_weapon()

func _physics_process(delta):#obsluga zdarzen co klatkowych
	var direction = get_global_mouse_position() - global_position

	_handle_player_movement()
	_handle_player_rotation(direction)
	_handle_weapon_action()
	_handle_player_camera(delta, direction)
	_handle_player_pick_up()

func _handle_player_movement():#obsluguje ruch gracza
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

func _handle_player_rotation(direction):#obsluguje rotacje gracza
	# Obrót w stronę kursora
	rotation = direction.angle() + 0.5*PI

func _handle_weapon_action():#obslugue wszelkie interakcje gracza
	var weapon = inventory.current_weapon

	if weapon != null:
		if weapon.is_in_group("weapon-machineGuns"):
			if Input.is_action_pressed("shoot"):
				weapon.shoot(global_position, self)
			else:
				weapon.spread_normalize()

		elif weapon.is_in_group("weapon-throwable"):
			if Input.is_action_just_pressed("shoot"):
				inventory.throw(velocity,weapon)

		else:
			if Input.is_action_just_pressed("shoot"):
				weapon.shoot(global_position, self)

		if Input.is_action_just_pressed("throw"):
			inventory.throw(velocity, weapon)

		if Input.is_action_pressed("reload"):
			if weapon.is_in_group("weapon-ranged"):
				if not inventory.reload_pending:
					inventory.reload(weapon)
			else:
				print("DEBUG - bron nie ranged false reload")

func _handle_player_camera(delta, direction):#obsluguje wszelkie nie naturalne zachowania kamery gracza
	if  Input.is_action_pressed("control_camera"):
		camera_direction=lerp(camera_direction,(direction-$Camera.get_offset())*camera_offset_limit*$Camera.zoom,camera_speed*delta)
		$Camera.set_offset(camera_direction)
	else:
		camera_direction=lerp(camera_direction,Vector2.ZERO,camera_speed*delta)
		$Camera.set_offset(camera_direction)

func _handle_player_pick_up():#obslguje poczatkowy proces podnoszenia broni
	if inventory.pick_up_check or inventory.ammo_pick_up_check:
		if Input.is_action_just_pressed("pick_up"):
			if inventory.nearest_weapon != null:
				inventory.nearest_weapon.pick_up(self)
			
			if inventory.nearest_ammo != null:
				inventory.nearest_ammo.ammo_pick_up(self)

func take_damage(amount: int):#obsluga damage'a
	hp -= amount
	if hp <= 0:
		die()
		return

func die() -> void:#obslguje smierc gracza oraz jej efekty
	print("smierc!!!!")
	pass
	#bedzie ekeran smierci czy cos ~~Kleks
