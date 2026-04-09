#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends CharacterBody2D

var dungeon: Node2D
#movement
@export var speed: float = 400
@export var dash_speed: float = 1200
@export var dash_duration: float = 0.25
@export var dash_cooldown: float = 0.5

var dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var attacking_from_left=false
#Death screen
var enemy_deaths: int = 0
var shots_fired: int = 0
var grenades_thrown: int = 0
signal death(enemy_deaths, shots_fired, grenades_thrown)

#weapon location tracker
var current_room: Node = null 
	
#camera
#@export var camera_speed: float = 4
#var camera_direction: Vector2 = Vector2.ZERO
#var camera_offset_limit: float = 0.5

#hp
@export var max_hp:int = 6
var hp: int

#inventory connector
@onready var inventory = $InventoryMenager

#van
var vanTilemap: TileMapLayer = null
var vanInput:bool = false
var isOnVan: bool = false

#SFX
@onready var audio_player_walk = $Sounds/Walk
@onready var audio_player_dash = $Sounds/Dash
@onready var audio_player_ambient = $Sounds/Ambient
@onready var audio_player_pick_up = $Sounds/PickUp
@onready var audio_player_throw = $Sounds/Throw
@onready var audio_player_Music = $Sounds/Music
@export var walk_sounds: Array[AudioStreamWAV] = []
@export var dash_sounds: Array[AudioStreamWAV] = []
@export var ambient_sounds: Array[AudioStreamWAV] = []
@export var pick_up_sounds: Array[AudioStreamWAV] = []
@export var throw_sounds: Array[AudioStreamWAV] = []
@export var music_sounds: Array[AudioStreamOggVorbis] = []

#signal to health_bar_display.gd
signal UI_HealthBarDisplay(max_hp, hp)

func _ready():
	dungeon = get_parent()
	hp = max_hp
	
	$"Gameplay_UI/CanvasLayer/WeaponDisplay".setup(inventory)
	UI_HealthBarDisplay.emit.call_deferred(max_hp, hp)
	_start_ambient_timer()
	_start_music_timer()
	

func _unhandled_input(event: InputEvent):#obsługa nie obsluzonych inputow
	if not inventory.weapon_container.is_empty():
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				inventory.next_weapon()
				$animation/top.play("pickup_"+inventory.current_weapon.weapon_name)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				inventory.previous_weapon()
				$animation/top.play("pickup_"+inventory.current_weapon.weapon_name)
		
		

func _physics_process(delta):#obsluga zdarzen co klatkowych
	if not dashing:
		_handle_player_rotation()
		_handle_player_movement()
	_handle_weapon_action()
	_handle_player_pick_up()
	
	if dungeon.name == "Dungeon":
		check_door_transition()

func _handle_player_movement():#obsluguje ruch gracza
	var weapon = inventory.current_weapon
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
		
	if Input.is_action_pressed("dash") and can_dash:
		dash()
		
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		if(weapon==null):
			$animation/top.play("unarmed")
		$animation/legs.play()
	else:
		if($animation/top.get_animation()=="unarmed"):
			$animation/top.stop()
		$animation/legs.stop()
	
	velocity = input_dir * speed
	
	if velocity != Vector2.ZERO:
		if not audio_player_walk.playing:
			audio_player_walk.stream = walk_sounds.pick_random()
			audio_player_walk.play()
		
	move_and_slide()
	
func dash():
	if not can_dash or dashing:
		return
	
	dashing = true
	can_dash = false
	dash_direction = (get_global_mouse_position() - global_position).normalized()
	set_collision_mask_value(7, false)
	
	audio_player_dash.stream = dash_sounds.pick_random()
	audio_player_dash.play()
	
	var dash_time = 0.0
	while dash_time < dash_duration:
		dash_time += get_process_delta_time()
		var progress = dash_time / dash_duration
		var current_speed = lerp(dash_speed, 0.0, progress)
		velocity = dash_direction * current_speed
		$animation/legs.visible=false
		$animation/top.play("dash")
		move_and_slide()
		await get_tree().process_frame
		
	dashing = false
	$animation/legs.visible=true
	if(inventory.current_weapon==null):
		$animation/top.play("unarmed")
	else:
		if inventory.current_weapon.is_in_group("weapon-white-switch"):
			$animation/top.play_backwards("swing_"+inventory.current_weapon.weapon_name+ ( "_left" if !attacking_from_left  else "_right") )
		else: $animation/top.play_backwards("pickup_"+inventory.current_weapon.weapon_name)
		$animation/top.pause()
	velocity = Vector2.ZERO
	set_collision_mask_value(7, true)
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	
func check_door_transition():
	var current_room = dungeon.get_current_room()
	if current_room == null:
		return
	
	var visible_layer: TileMapLayer = current_room.get_node_or_null("NavigationRegion2D/RoomLayout")
	if visible_layer == null:
		return
	
	var local_pos = position - current_room.position
	var tile_pos = visible_layer.local_to_map(local_pos)
	
	var atlas_coords = visible_layer.get_cell_atlas_coords(tile_pos)
	
	if atlas_coords == dungeon.DOOR_UP_ATLAS:
		dungeon.transition_to_room(Vector2.UP)
	elif atlas_coords == dungeon.DOOR_DOWN_ATLAS:
		dungeon.transition_to_room(Vector2.DOWN)
	elif atlas_coords == dungeon.DOOR_LEFT_ATLAS:
		dungeon.transition_to_room(Vector2.LEFT)
	elif atlas_coords == dungeon.DOOR_RIGHT_ATLAS:
		dungeon.transition_to_room(Vector2.RIGHT)

func _handle_player_rotation():#obsluguje rotacje gracza
	# Obrót w stronę kursora
	rotation = (get_global_mouse_position() - global_position).angle() + 0.5*PI
	if(get_position_delta()!=Vector2.ZERO):
		$animation/legs.rotation=-rotation +get_position_delta().angle() + 0.5*PI
	else:
		$animation/legs.rotation=0
func _handle_weapon_action():#obslugue wszelkie interakcje gracza
	var weapon = inventory.current_weapon

	if weapon != null:
		if weapon.is_in_group("weapon-machineGuns"):
			if Input.is_action_pressed("shoot"):
				weapon.shoot(global_position, self)
				shots_fired +=1
			else:
				weapon.spread_normalize()

		elif weapon.is_in_group("weapon-throwable"):
			if Input.is_action_just_pressed("shoot"):
				grenades_thrown += 1
				inventory.throw(velocity,weapon)
				audio_player_throw.stream = throw_sounds.pick_random()
				audio_player_throw.play()
				if(inventory.current_weapon!=null):
					$animation/top.play("pickup_"+inventory.current_weapon.weapon_name)
				else:
					$animation/top.play("unarmed")
		elif weapon.is_in_group("weapon-white"):
			if Input.is_action_just_pressed("shoot"):
				shots_fired +=1
				
				if(weapon.shoot(global_position, self)):
					if weapon.is_in_group("weapon-white-switch"):
						$animation/top.play("swing_"+weapon.weapon_name+ ( "_left" if attacking_from_left  else "_right") )
						attacking_from_left=!attacking_from_left
					else:
						$animation/top.play("swing_"+weapon.weapon_name)
		else:
			if Input.is_action_just_pressed("shoot"):
				shots_fired +=1
				weapon.shoot(global_position, self)

		if Input.is_action_just_pressed("throw"):
			inventory.throw(velocity, weapon)
			audio_player_throw.stream = throw_sounds.pick_random()
			audio_player_throw.play()
			if(inventory.current_weapon!=null):
				$animation/top.play("pickup_"+inventory.current_weapon.weapon_name)
			else:
				$animation/top.play("unarmed")

		if Input.is_action_pressed("reload"):
			if weapon.is_in_group("weapon-ranged"):
				if not inventory.reload_pending:
					inventory.reload(weapon)
			else:
				print("DEBUG - bron nie ranged false reload")

#func _handle_player_camera(delta, direction):#obsluguje wszelkie nie naturalne zachowania kamery gracza
#	if  Input.is_action_pressed("control_camera"):
#		camera_direction=lerp(camera_direction,(direction-$Camera.get_offset())*camera_offset_limit*$Camera.zoom,camera_speed*delta)
#		$Camera.set_offset(camera_direction)
#	else:
#		camera_direction=lerp(camera_direction,Vector2.ZERO,camera_speed*delta)
#		$Camera.set_offset(camera_direction)

func _handle_player_pick_up():#obslguje poczatkowy proces podnoszenia broni
	if inventory.pick_up_check or inventory.ammo_pick_up_check:
		if Input.is_action_just_pressed("pick_up"):
			if inventory.nearest_weapon != null:
				inventory.nearest_weapon.pick_up(self)
				var picked_up=inventory.current_weapon.weapon_name
				$animation/top.play("pickup_"+picked_up)
				_audio_pick_up_play()
			
			if inventory.nearest_ammo != null:
				inventory.nearest_ammo.ammo_pick_up(self)
				_audio_pick_up_play()

func take_damage(amount: int):#obsluga damage'a
	hp -= amount
	emit_signal("UI_HealthBarDisplay", max_hp, hp)
	if hp <= 0:
		die()
		return

func die() -> void:#obslguje smierc gracza oraz jej efekty
	visible = false
	GameState.push_screen("death")
	$Gameplay_UI._change($Gameplay_UI, false)
	emit_signal("death", enemy_deaths, shots_fired, grenades_thrown)

func heal(amount_of_healing, body) -> void:
	if hp == max_hp:
		return
	
	var calc_add = min(amount_of_healing, max_hp - hp)
	hp += calc_add
	body.queue_free()
	emit_signal("UI_HealthBarDisplay", max_hp, hp)
	_audio_pick_up_play()

func change_door_collision(mode: bool):
	set_collision_mask_value(8, mode)

func _start_ambient_timer() -> void:
	await get_tree().create_timer(randf_range(10.0, 30.0)).timeout
	audio_player_ambient.stream = ambient_sounds.pick_random()
	audio_player_ambient.play()
	await audio_player_ambient.finished
	_start_ambient_timer()

func _audio_pick_up_play() -> void:
	audio_player_pick_up.stream = pick_up_sounds.pick_random()
	audio_player_pick_up.play()

func _start_music_timer() -> void:
	audio_player_Music.stream = music_sounds.pick_random()
	audio_player_Music.play()
	
func _on_music_finished() -> void:
	audio_player_Music.stream = music_sounds.pick_random()
	audio_player_Music.play()
