extends Node2D

signal floor_generated
signal room_changed(new_room_pos: Vector2i)

@onready var camera: Camera2D = get_node("/root/Main/Camera")

@export var room_number: int = GameState.room_number #Kleks GLOBAL skrypt game_state.gd
@export var room_folder_path: String = "res://Scenes/Floors/ValidRooms"

const ROOM_SIZE: Vector2 = Vector2(1152, 768)
const PLAYER: PackedScene = preload("res://Scenes/Entities/Other/Player/Player.tscn")
const SPAWN_ROOM: PackedScene = preload("res://Scenes/Floors/StartingRooms/StartingRoom.tscn")
const BOSS_ROOM: PackedScene = preload("res://Scenes/Floors/BossRooms/RoomBoss1.tscn")

const DOOR_UP_ATLAS: Vector2i = Vector2i(12, 1)
const DOOR_DOWN_ATLAS: Vector2i = Vector2i(12, 4)
const DOOR_LEFT_ATLAS: Vector2i = Vector2i(12, 2)
const DOOR_RIGHT_ATLAS: Vector2i = Vector2i(12, 3)

const DOOR_UP_POS_LEFT: Vector2i = Vector2i(17, 0)
const DOOR_UP_POS_RIGHT: Vector2i = Vector2i(18, 0)
const DOOR_DOWN_POS_LEFT: Vector2i = Vector2i(17, 23)
const DOOR_DOWN_POS_RIGHT: Vector2i = Vector2i(18, 23)
const DOOR_LEFT_POS_TOP: Vector2i = Vector2i(0, 11)
const DOOR_LEFT_POS_BOTTOM: Vector2i = Vector2i(0, 12)
const DOOR_RIGHT_POS_TOP: Vector2i = Vector2i(35, 11)
const DOOR_RIGHT_POS_BOTTOM: Vector2i = Vector2i(35, 12)

var room_scenes: Array[PackedScene] = []
var room_instances := {}
var room_positions: Array[Vector2i] = []
var current_room_pos: Vector2i = Vector2i.ZERO
var player: Node2D
var visited_rooms: Array[Vector2i] = [Vector2i.ZERO]
var boss_room_pos: Vector2i

var camera_target: Vector2 = ROOM_SIZE / 2

#seed
var current_seed: int = 0

var cleared_rooms: Array[Vector2i] = []

func _ready():
	if PlayerData.dungeon_seed == 0:
		current_seed = randi()
		PlayerData.dungeon_seed = current_seed
	else:
		current_seed = PlayerData.dungeon_seed
	seed(current_seed)
	PlayerData.floor_stage = "Dungeon"
	print("SEED: ", current_seed)
	colorize()
	preload_rooms()
	generate_floor()
	spawn_all_rooms()
	spawn_player()
	call_deferred("boss_defeated")#~~Kleks Do testowania
	PlayerData.call_deferred("_save")

func _process(delta):
	camera.position = lerp(camera.position, camera_target, 5.0 * delta)

func colorize():
	var room_shader=load("res://Assets/Tilesets/room_hue_shift.material");
	var d_HSV=Vector3(randi()%61-30,randi()%200-100,randi()%40-20);
	room_shader.set_shader_parameter("d_HSV", d_HSV)
	print(d_HSV)
	return

func preload_rooms():
	var dir := DirAccess.open(room_folder_path)
	if dir == null:
		push_error("Could not open room folder: " + room_folder_path)
		return
	
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn") and file_name != "Room0.tscn" and file_name != "Room.tscn":
			var full_path := room_folder_path + "/" + file_name
			var scene = load(full_path)
			if scene is PackedScene:
				room_scenes.append(scene)
				print("Loaded room scene:", full_path)
	
	if room_scenes.is_empty():
		push_error("No room scenes found in " + room_folder_path)

func generate_floor():
	if room_scenes.is_empty():
		return
	
	room_positions.clear()
	
	var start_pos := Vector2i(0, 0)
	room_positions.append(start_pos)
	var visited_positions: Array[Vector2i] = [start_pos]
	
	# Positions that can never have a room placed
	var forbidden: Array[Vector2i] = [
		Vector2i(0, 1),   # down from start
		Vector2i(-1, 0),  # left from start
		Vector2i(1, 0),   # right from start
	]
	
	var current_pos := start_pos
	var target_rooms = floor(room_number * 2 / 3)
	var directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	while room_positions.size() < target_rooms:
		directions.shuffle()
		var placed := false
		
		for dir in directions:
			var next_pos = current_pos + dir
			
			if not room_positions.has(next_pos) and not forbidden.has(next_pos) and is_valid_position(next_pos):
				room_positions.append(next_pos)
				visited_positions.append(next_pos)
				current_pos = next_pos
				placed = true
				break
		
		if not placed:
			if visited_positions.size() > 1:
				visited_positions.pop_back()
				current_pos = visited_positions[-1]
	
	var branch_count: int = room_number - target_rooms
	add_branch_rooms(branch_count, forbidden)
	
	var farthest_room := room_positions[0]
	for room in room_positions:
		if Vector2i(0,0).distance_to(room) > Vector2i(0,0).distance_to(farthest_room):
			farthest_room = room
	var angle := Vector2(farthest_room.x, farthest_room.y).angle()
	var side = floor(2*angle/PI)
	if side == 0:
		boss_room_pos = farthest_room + Vector2i.RIGHT
		room_positions.append(boss_room_pos)
	elif side == 1:
		boss_room_pos = farthest_room + Vector2i.DOWN
		room_positions.append(boss_room_pos)
	elif side == 2:
		boss_room_pos = farthest_room + Vector2i.LEFT
		room_positions.append(boss_room_pos)
	else:
		boss_room_pos = farthest_room + Vector2i.UP
		room_positions.append(boss_room_pos)

	print("Generated floor with ", room_positions.size(), " rooms")
	call_deferred("emit_signal", "floor_generated")

func is_valid_position(pos: Vector2i) -> bool:
	var neighbor_count := 0
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if room_positions.has(pos + dir):
			neighbor_count += 1
	
	return neighbor_count <= 2

func add_branch_rooms(branch_count: int, forbidden: Array[Vector2i] = []):
	var possible_positions: Array[Vector2i] = []
	
	for room_pos in room_positions:
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var branch_pos = room_pos + dir
			if not room_positions.has(branch_pos) and not forbidden.has(branch_pos) and is_valid_position(branch_pos):
				if not possible_positions.has(branch_pos):
					possible_positions.append(branch_pos)
	
	possible_positions.shuffle()
	
	for i in range(mini(branch_count, possible_positions.size())):
		room_positions.append(possible_positions[i])

func spawn_all_rooms():
	for child in get_children():
		child.queue_free()
	
	room_instances.clear()
	
	for i in range(room_positions.size()):
		var room_pos = room_positions[i]
		var room_instance: Room
		
		if room_pos == Vector2i(0, 0):
			room_instance = SPAWN_ROOM.instantiate()
			add_child(room_instance)
			room_instance.position = Vector2(room_pos) * ROOM_SIZE
			room_instance.setup(room_pos, "spawn")
		elif room_pos == boss_room_pos:
			room_instance = BOSS_ROOM.instantiate()
			add_child(room_instance)
			room_instance.position = Vector2(room_pos) * ROOM_SIZE
			room_instance.setup(room_pos, "boss")
			room_instance.boss_defeated.connect(boss_defeated)
		else:
			room_instance = room_scenes.pick_random().instantiate()
			add_child(room_instance)
			room_instance.position = Vector2(room_pos) * ROOM_SIZE
			room_instance.setup(room_pos, "")
		
		room_instances[room_pos] = room_instance
		setup_room_doors(room_instance, room_pos)
		
		if room_pos == Vector2i.ZERO:
			room_instance.enter_room()
		else:
			room_instance.visible = false
		
		room_instance.room_cleared.connect(clear_room)

func setup_room_doors(room: Room, pos: Vector2i):
	var visible_layer: TileMapLayer = room.get_node_or_null("NavigationRegion2D/RoomLayout")
	
	print(room.scene_file_path)
	if visible_layer == null:
		push_warning("Room at " + str(pos) + " has no RoomLayout TileMapLayer")
		return
	
	var has_up := room_positions.has(pos + Vector2i.UP)
	var has_down := room_positions.has(pos + Vector2i.DOWN)
	var has_left := room_positions.has(pos + Vector2i.LEFT)
	var has_right := room_positions.has(pos + Vector2i.RIGHT)
	
	print(room.doors)
	
	if pos == Vector2i.ZERO:
		if room_positions.has(pos + Vector2i.UP):
			visible_layer.set_cell(DOOR_UP_POS_LEFT, 2, DOOR_UP_ATLAS)
			visible_layer.set_cell(DOOR_UP_POS_RIGHT, 2, DOOR_UP_ATLAS)
		return
	
	if has_up:
		visible_layer.set_cell(DOOR_UP_POS_LEFT, 2, DOOR_UP_ATLAS)
		visible_layer.set_cell(DOOR_UP_POS_RIGHT, 2, DOOR_UP_ATLAS)
	else:
		room.doors["up"].visible = false
	
	if has_down:
		visible_layer.set_cell(DOOR_DOWN_POS_LEFT, 2, DOOR_DOWN_ATLAS)
		visible_layer.set_cell(DOOR_DOWN_POS_RIGHT, 2, DOOR_DOWN_ATLAS)
	else:
		room.doors["down"].visible = false
	
	if has_left:
		visible_layer.set_cell(DOOR_LEFT_POS_TOP, 2, DOOR_LEFT_ATLAS)
		visible_layer.set_cell(DOOR_LEFT_POS_BOTTOM, 2, DOOR_LEFT_ATLAS)
	else:
		room.doors["left"].visible = false
	
	if has_right:
		visible_layer.set_cell(DOOR_RIGHT_POS_TOP, 2, DOOR_RIGHT_ATLAS)
		visible_layer.set_cell(DOOR_RIGHT_POS_BOTTOM, 2, DOOR_RIGHT_ATLAS)
	else:
		room.doors["right"].visible = false

func spawn_player():
	player = PLAYER.instantiate()
	add_child(player)
	player.position = ROOM_SIZE/2
	current_room_pos = Vector2i.ZERO
	camera.position = ROOM_SIZE / 2
	
	player.current_room = room_instances.get(current_room_pos)
	player.set_collision_mask_value(8, false)

func transition_to_room(direction: Vector2):
	var next_pos = current_room_pos + Vector2i(direction.x, direction.y)
	
	if not room_positions.has(next_pos):
		return
	
	var current_room: Room = room_instances.get(current_room_pos)
	var next_room: Room = room_instances.get(next_pos)
	
	if current_room:
		current_room.exit_room()
	
	if next_room:
		next_room.enter_room()
		if next_room.is_cleared:
			player.set_collision_mask_value(8, false)
		else:
			player.set_collision_mask_value(8, true)
		current_room_pos = next_pos
		
	var offset = direction * 64
	player.position = player.position + offset
	
	player.current_room = next_room
	
	if not visited_rooms.has(next_pos):
		visited_rooms.append(next_pos)
	
	camera_target = Vector2(next_pos) * ROOM_SIZE + (ROOM_SIZE / 2)
	
	room_changed.emit(next_pos)

func boss_defeated():
	var carDoor = room_instances[Vector2i(0,0)].get_node_or_null("CarDoor")
	if carDoor == null:
		print("Brak carDoor")
	else:
		carDoor.can_leave = true

func get_current_room() -> Room:
	return room_instances.get(current_room_pos)

func reveal_all_rooms():
	for room in room_instances.values():
		room.visible = true
		
func clear_room():
	player.set_collision_mask_value(8, false)
	cleared_rooms.append(current_room_pos)
	
