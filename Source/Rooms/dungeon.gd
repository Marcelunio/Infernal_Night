extends Node2D

signal floor_generated
signal room_changed(new_room_pos: Vector2i)

@onready var camera: Camera2D = get_node("/root/Main/Camera")

@export var min_rooms: int = GameState.minimum_rooms #Kleks GLOBAL skrypt game_state.gd
@export var max_rooms: int = GameState.maximum_rooms
@export var room_folder_path: String = "res://Scenes/Floors/ValidRooms"

const ROOM_SIZE: Vector2 = Vector2(1152, 768)
const PLAYER: PackedScene = preload("res://Scenes/Entities/Other/Player/Player.tscn")
const SPAWN_ROOM: PackedScene = preload("res://Scenes/Floors/ValidRooms/Room0.tscn")

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

var camera_target: Vector2 = ROOM_SIZE / 2

func _ready():
	randomize()
	preload_rooms()
	generate_floor()
	spawn_all_rooms()
	spawn_player()

func _process(delta):
	camera.position = lerp(camera.position, camera_target, 5.0 * delta)

func preload_rooms():
	var dir := DirAccess.open(room_folder_path)
	if dir == null:
		push_error("Could not open room folder: " + room_folder_path)
		return
	
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn") and file_name != "Room0.tscn":
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
	
	var current_pos := start_pos
	var target_rooms := randi_range(min_rooms, max_rooms)
	var directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	while room_positions.size() < target_rooms:
		directions.shuffle()
		var placed := false
		
		for dir in directions:
			var next_pos = current_pos + dir
			
			if not room_positions.has(next_pos) and is_valid_position(next_pos):
				room_positions.append(next_pos)
				visited_positions.append(next_pos)
				current_pos = next_pos
				placed = true
				break
		
		if not placed:
			if visited_positions.size() > 1:
				visited_positions.pop_back()
				current_pos = visited_positions[-1]
	
	add_branch_rooms()
	
	print("Generated floor with ", room_positions.size(), " rooms")
	
	call_deferred("emit_signal", "floor_generated")

func is_valid_position(pos: Vector2i) -> bool:
	var neighbor_count := 0
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if room_positions.has(pos + dir):
			neighbor_count += 1
	
	return neighbor_count <= 2

func add_branch_rooms():
	var branch_count: int = mini(3, room_positions.size() / 3)
	var possible_positions: Array[Vector2i] = []
	
	for room_pos in room_positions:
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var branch_pos = room_pos + dir
			if not room_positions.has(branch_pos) and is_valid_position(branch_pos):
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
		else:
			room_instance = room_scenes.pick_random().instantiate()
		
		add_child(room_instance)
		room_instance.position = Vector2(room_pos) * ROOM_SIZE
		
		room_instance.setup(room_pos)
		
		room_instances[room_pos] = room_instance
		setup_room_doors(room_instance, room_pos)
		
		if room_pos == Vector2i.ZERO:
			room_instance.enter_room()
		else:
			room_instance.exit_room()

func setup_room_doors(room: Node2D, pos: Vector2i):
	var visible_layer: TileMapLayer = room.get_node_or_null("NavigationRegion2D/RoomLayout")
	
	if visible_layer == null:
		push_warning("Room at " + str(pos) + " has no RoomLayout TileMapLayer")
		return
	
	var has_up := room_positions.has(pos + Vector2i.UP)
	var has_down := room_positions.has(pos + Vector2i.DOWN)
	var has_left := room_positions.has(pos + Vector2i.LEFT)
	var has_right := room_positions.has(pos + Vector2i.RIGHT)
	
	if has_up:
		visible_layer.set_cell(DOOR_UP_POS_LEFT, 2, DOOR_UP_ATLAS)
		visible_layer.set_cell(DOOR_UP_POS_RIGHT, 2, DOOR_UP_ATLAS)
	else:
		visible_layer.set_cell(DOOR_UP_POS_LEFT, 2, Vector2i(2,0))
		visible_layer.set_cell(DOOR_UP_POS_RIGHT, 2, Vector2i(2,0))
	
	if has_down:
		visible_layer.set_cell(DOOR_DOWN_POS_LEFT, 2, DOOR_DOWN_ATLAS)
		visible_layer.set_cell(DOOR_DOWN_POS_RIGHT, 2, DOOR_DOWN_ATLAS)
	else:
		visible_layer.set_cell(DOOR_DOWN_POS_LEFT, 2, Vector2i(2,0))
		visible_layer.set_cell(DOOR_DOWN_POS_RIGHT, 2, Vector2i(2,0))
	
	if has_left:
		visible_layer.set_cell(DOOR_LEFT_POS_TOP, 2, DOOR_LEFT_ATLAS)
		visible_layer.set_cell(DOOR_LEFT_POS_BOTTOM, 2, DOOR_LEFT_ATLAS)
	else:
		visible_layer.set_cell(DOOR_LEFT_POS_TOP, 2, Vector2i(0,2))
		visible_layer.set_cell(DOOR_LEFT_POS_BOTTOM, 2, Vector2i(0,2))
	
	if has_right:
		visible_layer.set_cell(DOOR_RIGHT_POS_TOP, 2, DOOR_RIGHT_ATLAS)
		visible_layer.set_cell(DOOR_RIGHT_POS_BOTTOM, 2, DOOR_RIGHT_ATLAS)
	else:
		visible_layer.set_cell(DOOR_RIGHT_POS_TOP, 2, Vector2i(0,2))
		visible_layer.set_cell(DOOR_RIGHT_POS_BOTTOM, 2, Vector2i(0,2))

func spawn_player():
	player = PLAYER.instantiate()
	player.vanTilemap = get_node("Room/NavigationRegion2D/RoomLayout")#Kleks
	add_child(player)
	player.position = ROOM_SIZE/2
	current_room_pos = Vector2i.ZERO
	camera.position = ROOM_SIZE / 2
	
	player.current_room = room_instances.get(current_room_pos)

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
		current_room_pos = next_pos
		
	var offset = direction * 64
	player.position = player.position + offset
	
	player.current_room = next_room#Kleks
	
	if not visited_rooms.has(next_pos):
		visited_rooms.append(next_pos)
	
	camera_target = Vector2(next_pos) * ROOM_SIZE + (ROOM_SIZE / 2)
	
	room_changed.emit(next_pos)

func get_current_room() -> Room:
	return room_instances.get(current_room_pos)

func reveal_all_rooms():
	for room in room_instances.values():
		room.visible = true
