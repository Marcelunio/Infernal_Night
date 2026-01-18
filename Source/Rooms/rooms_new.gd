extends Node2D

const ROOM_FOLDER_PATH: String = "res://Scenes/Floors/ValidRooms"
const MAX_ROOMS: int = 10
const MIN_ROOMS: int = 5
const ROOM_SIZE: Vector2 = Vector2(768, 512)  # 24 tiles * 32px, 16 tiles * 32px
const PLAYER: PackedScene = preload("res://Scenes/Entities/Other/Player/Player.tscn")

# Atlas coordinates for door tiles in LayerInvisible TileMapLayer
# Each door is 2 tiles - adjust these to match your tileset atlas positions
# UP/DOWN doors: 2 horizontal tiles
const DOOR_UP_ATLAS: Vector2i = Vector2i(12, 1)
const DOOR_DOWN_ATLAS: Vector2i = Vector2i(12, 4)

# LEFT/RIGHT doors: 2 vertical tiles
const DOOR_LEFT_ATLAS: Vector2i = Vector2i(12, 2)
const DOOR_RIGHT_ATLAS: Vector2i = Vector2i(12, 3)

# Tilemap coordinates where doors are placed in rooms
const DOOR_UP_POS_LEFT: Vector2i = Vector2i(11, 0)
const DOOR_UP_POS_RIGHT: Vector2i = Vector2i(12, 0)
const DOOR_DOWN_POS_LEFT: Vector2i = Vector2i(11, 15)
const DOOR_DOWN_POS_RIGHT: Vector2i = Vector2i(12, 15)
const DOOR_LEFT_POS_TOP: Vector2i = Vector2i(0, 7)
const DOOR_LEFT_POS_BOTTOM: Vector2i = Vector2i(0, 8)
const DOOR_RIGHT_POS_TOP: Vector2i = Vector2i(23, 7)
const DOOR_RIGHT_POS_BOTTOM: Vector2i = Vector2i(23, 8)

var room_scenes: Array[PackedScene] = []
var room_instances := {}  # Vector2i -> Room Node2D
var room_positions: Array[Vector2i] = []
var current_room_pos: Vector2i = Vector2i.ZERO
var player: Node2D

func _ready():
	randomize()
	preload_rooms()
	generate_floor()
	spawn_all_rooms()
	spawn_player()

func preload_rooms():
	var dir := DirAccess.open(ROOM_FOLDER_PATH)
	if dir == null:
		push_error("Could not open room folder: " + ROOM_FOLDER_PATH)
		return
	
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			var full_path := ROOM_FOLDER_PATH + "/" + file_name
			var scene = load(full_path)
			if scene is PackedScene:
				room_scenes.append(scene)
				print("Loaded room scene:", full_path)
	
	if room_scenes.is_empty():
		push_error("No room scenes found in " + ROOM_FOLDER_PATH)

func generate_floor():
	if room_scenes.is_empty():
		return
	
	room_positions.clear()
	
	# Start at origin with the starting room
	var start_pos := Vector2i(0, 0)
	room_positions.append(start_pos)
	var visited_positions: Array[Vector2i] = [start_pos]
	
	# Generate main path
	var current_pos := start_pos
	var target_rooms := randi_range(MIN_ROOMS, MAX_ROOMS)
	var directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	# Create main path with backtracking
	for i in range(target_rooms - 1):
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
			# Backtrack if stuck
			if visited_positions.size() > 1:
				visited_positions.pop_back()
				current_pos = visited_positions[-1]
	
	# Add some branch rooms
	add_branch_rooms()
	
	print("Generated floor with ", room_positions.size(), " rooms")

func is_valid_position(pos: Vector2i) -> bool:
	# Prevent rooms from being too clustered
	var neighbor_count := 0
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if room_positions.has(pos + dir):
			neighbor_count += 1
	
	# Allow max 2 neighbors to prevent cross-shaped intersections
	return neighbor_count <= 2

func add_branch_rooms():
	var branch_count: int = mini(3, room_positions.size() / 3)  # Integer division intended
	var possible_positions: Array[Vector2i] = []
	
	# Find positions adjacent to existing rooms
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
	# Clear existing rooms
	for child in get_children():
		child.queue_free()
	
	room_instances.clear()
	
	# Spawn all rooms at once (like Isaac)
	for i in range(room_positions.size()):
		var room_pos = room_positions[i]
		var room_instance: Node2D
		
		# Use first room scene for starting room (0,0), random for others
		if room_pos == Vector2i(0, 0):
			room_instance = room_scenes[0].instantiate()
		else:
			room_instance = room_scenes.pick_random().instantiate()
		
		add_child(room_instance)
		
		# Position the room in world space
		room_instance.position = Vector2(room_pos) * ROOM_SIZE
		
		# Store reference
		room_instances[room_pos] = room_instance
		
		# Setup doors based on neighbors
		setup_room_doors(room_instance, room_pos)
		
		# Initially hide all rooms except starting room
		if room_pos != Vector2i.ZERO:
			room_instance.visible = false

func setup_room_doors(room: Node2D, pos: Vector2i):
	# Get the LayerInvisible TileMapLayer
	var invisible_layer: TileMapLayer = room.get_node_or_null("LayerInvisible")
	var visible_layer: TileMapLayer = room.get_node_or_null("LayerVisible")
	
	if invisible_layer == null:
		push_warning("Room at " + str(pos) + " has no LayerInvisible TileMapLayer")
		return
	if visible_layer == null:
		push_warning("Room at " + str(pos) + " has no LayerVisible TileMapLayer")
		return
	
	invisible_layer.visible = false
	
	# Check which neighbors exist
	var has_up := room_positions.has(pos + Vector2i.UP)
	var has_down := room_positions.has(pos + Vector2i.DOWN)
	var has_left := room_positions.has(pos + Vector2i.LEFT)
	var has_right := room_positions.has(pos + Vector2i.RIGHT)
	
	# Place/erase UP door (2 horizontal tiles)
	if has_up:
		visible_layer.set_cell(DOOR_UP_POS_LEFT, 2, DOOR_UP_ATLAS)
		visible_layer.set_cell(DOOR_UP_POS_RIGHT, 2, DOOR_UP_ATLAS)
	else:
		visible_layer.set_cell(DOOR_UP_POS_LEFT, 2, DOOR_UP_ATLAS)
		visible_layer.set_cell(DOOR_UP_POS_RIGHT, 2, DOOR_UP_ATLAS)
	
	# Place/erase DOWN door (2 horizontal tiles)
	if has_down:
		visible_layer.set_cell(DOOR_DOWN_POS_LEFT, 2, DOOR_DOWN_ATLAS)
		visible_layer.set_cell(DOOR_DOWN_POS_RIGHT, 2, DOOR_DOWN_ATLAS)
	else:
		visible_layer.erase_cell(DOOR_DOWN_POS_LEFT)
		visible_layer.erase_cell(DOOR_DOWN_POS_RIGHT)
	
	# Place/erase LEFT door (2 vertical tiles)
	if has_left:
		visible_layer.set_cell(DOOR_LEFT_POS_TOP, 2, DOOR_LEFT_ATLAS)
		visible_layer.set_cell(DOOR_LEFT_POS_BOTTOM, 2, DOOR_LEFT_ATLAS)
	else:
		visible_layer.erase_cell(DOOR_LEFT_POS_TOP)
		visible_layer.erase_cell(DOOR_LEFT_POS_BOTTOM)
	
	# Place/erase RIGHT door (2 vertical tiles)
	if has_right:
		visible_layer.set_cell(DOOR_RIGHT_POS_TOP, 2, DOOR_RIGHT_ATLAS)
		visible_layer.set_cell(DOOR_RIGHT_POS_BOTTOM, 2, DOOR_RIGHT_ATLAS)
	else:
		visible_layer.erase_cell(DOOR_RIGHT_POS_TOP)
		visible_layer.erase_cell(DOOR_RIGHT_POS_BOTTOM)

func spawn_player():
	player = PLAYER.instantiate()
	add_child(player)
	# Spawn in the starting room center
	player.position = ROOM_SIZE/2
	current_room_pos = Vector2i.ZERO

# Call this when player enters a door
func transition_to_room(direction: Vector2i):
	var next_pos = current_room_pos + direction
	
	if not room_positions.has(next_pos):
		return  # No room in that direction
	
	# Hide current room
	if room_instances.has(current_room_pos):
		room_instances[current_room_pos].visible = false
	
	# Show next room
	if room_instances.has(next_pos):
		room_instances[next_pos].visible = true
		current_room_pos = next_pos
		
		# Move player to opposite side of new room
		var room_center = Vector2(next_pos) * ROOM_SIZE
		var offset = Vector2.ZERO
		
		# Position player at opposite door
		if direction == Vector2i.UP:
			offset = Vector2(0, ROOM_SIZE.y / 2 - 50)  # Near bottom door
		elif direction == Vector2i.DOWN:
			offset = Vector2(0, -ROOM_SIZE.y / 2 + 50)  # Near top door
		elif direction == Vector2i.LEFT:
			offset = Vector2(ROOM_SIZE.x / 2 - 50, 0)  # Near right door
		elif direction == Vector2i.RIGHT:
			offset = Vector2(-ROOM_SIZE.x / 2 + 50, 0)  # Near left door
		
		player.position = room_center + offset

func get_current_room() -> Node2D:
	return room_instances.get(current_room_pos)

func reveal_all_rooms():
	# Debug function to show all rooms at once
	for room in room_instances.values():
		room.visible = true
