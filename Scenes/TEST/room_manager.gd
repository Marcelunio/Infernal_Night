extends Node2D

var room_scenes = [
	"res://Scenes/TEST/Room1.tscn",
	"res://Scenes/TEST/Room2.tscn",
	"res://Scenes/TEST/Room3.tscn",
	"res://Scenes/TEST/Room4.tscn",
	"res://Scenes/TEST/Room5.tscn"
]

@export var rooms_per_floor = 10

# World tilemaps (merged from all rooms)
var world_visible_tilemap: TileMapLayer
var world_invisible_tilemap: TileMapLayer
var player: CharacterBody2D

var floor_layout = {}
var current_room_coord = Vector2(0, 0)

const ROOM_WIDTH = 32
const ROOM_HEIGHT = 24

var opposite_direction = {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east"
}

func _ready():
	setup_world_tilemaps()
	randomize()
	generate_floor()
	build_world()
	spawn_player()

func setup_world_tilemaps():
	# Create world visible tilemap
	world_visible_tilemap = TileMapLayer.new()
	world_visible_tilemap.name = "WorldVisibleTileMap"
	
	# Create world invisible tilemap
	world_invisible_tilemap = TileMapLayer.new()
	world_invisible_tilemap.name = "WorldInvisibleTileMap"
	
	# Copy tilesets from RoomStart
	var start_room = load("res://Scenes/TEST/RoomStart.tscn").instantiate()
	var sample_visible = start_room.get_node("Visual")
	var sample_invisible = start_room.get_node("Hidden")
	
	world_visible_tilemap.tile_set = sample_visible.tile_set
	world_invisible_tilemap.tile_set = sample_invisible.tile_set
	
	start_room.queue_free()
	
	add_child(world_visible_tilemap)
	add_child(world_invisible_tilemap)

func generate_floor():
	print("=== Generating New Floor ===")
	floor_layout.clear()
	
	floor_layout[Vector2(0, 0)] = {
		"scene_path": "res://Scenes/TEST/RoomStart.tscn",
		"visited": false
	}
	
	var rooms_to_process = [Vector2(0, 0)]
	var rooms_generated = 1
	var attempts = 0
	var max_attempts = rooms_per_floor * 10
	
	while rooms_generated < rooms_per_floor and attempts < max_attempts:
		attempts += 1
		
		if rooms_to_process.is_empty():
			break
		
		var current_pos = rooms_to_process.pop_front()
		
		# Try all 4 directions - no need to load room to check doors
		var directions = ["north", "south", "east", "west"]
		directions.shuffle()
		
		for door_direction in directions:
			if rooms_generated >= rooms_per_floor:
				break
			
			var neighbor_pos = get_neighbor_position(current_pos, door_direction)
			
			# Skip if room already exists
			if floor_layout.has(neighbor_pos):
				continue
			
			# Random chance to place room (70%)
			if randf() > 0.7:
				continue
			
			# Pick random room - no need to check doors since we create them
			var random_scene = get_random_room_scene()
			
			# Place the room
			floor_layout[neighbor_pos] = {
				"scene_path": random_scene,
				"visited": false
			}
			
			rooms_to_process.append(neighbor_pos)
			rooms_generated += 1
			
			print("Generated room %d at %s: %s" % [rooms_generated, neighbor_pos, random_scene.get_file()])
	
	print("Floor generation complete: %d rooms" % floor_layout.size())

func build_world():
	for room_coord in floor_layout.keys():
		var room_data = floor_layout[room_coord]
		var room_scene = load(room_data.scene_path).instantiate()
		# REMOVED: room_scene._ready()  <- Don't call this manually
		
		var tile_offset = Vector2i(
			int(room_coord.x) * ROOM_WIDTH,
			int(room_coord.y) * ROOM_HEIGHT
		)
		
		room_scene.merge_tilemaps_to(world_visible_tilemap, world_invisible_tilemap, tile_offset)
		room_scene.queue_free()
	
	for room_coord in floor_layout.keys():
		remove_connecting_walls(room_coord)
	
	print("World built!")

func remove_connecting_walls(room_coord: Vector2):
	var tile_offset = Vector2i(
		int(room_coord.x) * ROOM_WIDTH,
		int(room_coord.y) * ROOM_HEIGHT
	)
	
	# Remove walls where rooms connect
	if floor_layout.has(room_coord + Vector2(0, -1)):  # North
		for x in range(15, 17):
			world_visible_tilemap.set_cell(Vector2i(tile_offset.x + x, tile_offset.y),0,Vector2i(1,1))
			world_invisible_tilemap.set_cell(Vector2i(tile_offset.x + x, tile_offset.y),1,Vector2i(2,0))
	
	if floor_layout.has(room_coord + Vector2(0, 1)):   # South
		for x in range(15, 17):
			world_visible_tilemap.set_cell(Vector2i(tile_offset.x + x, tile_offset.y + ROOM_HEIGHT - 1),0,Vector2i(1,1))
			world_invisible_tilemap.set_cell(Vector2i(tile_offset.x + x, tile_offset.y + ROOM_HEIGHT - 1),1,Vector2i(2,1))
	
	if floor_layout.has(room_coord + Vector2(1, 0)):   # East
		for y in range(11, 13):
			world_visible_tilemap.set_cell(Vector2i(tile_offset.x + ROOM_WIDTH - 1, tile_offset.y + y), 0, Vector2i(1,1))
			world_invisible_tilemap.set_cell(Vector2i(tile_offset.x + ROOM_WIDTH - 1, tile_offset.y + y), 1, Vector2i(3,0))
	
	if floor_layout.has(room_coord + Vector2(-1, 0)):  # West
		for y in range(11, 13):
			world_visible_tilemap.set_cell(Vector2i(tile_offset.x, tile_offset.y + y), 0, Vector2i(1,1))
			world_invisible_tilemap.set_cell(Vector2i(tile_offset.x, tile_offset.y + y), 1, Vector2i(3,1))

func get_random_room_scene() -> String:
	return room_scenes[randi() % room_scenes.size()]

func get_neighbor_position(pos: Vector2, direction: String) -> Vector2:
	match direction:
		"north":
			return pos + Vector2(0, -1)
		"south":
			return pos + Vector2(0, 1)
		"east":
			return pos + Vector2(1, 0)
		"west":
			return pos + Vector2(-1, 0)
	return pos

func spawn_player():
	var player_scene = preload("res://Scenes/Entities/Player.tscn")
	player = player_scene.instantiate()
	player.entered_door.connect(_on_player_entered_door)
	add_child(player)
	
	var spawn_pos = Vector2(12, 16) * Vector2(world_visible_tilemap.tile_set.tile_size)
	player.global_position = spawn_pos

func _on_player_entered_door(tile_pos: Vector2i):
	var room_coord = Vector2(
		floor(tile_pos.x / float(ROOM_WIDTH)),
		floor(tile_pos.y / float(ROOM_HEIGHT))
	)
	
	var atlas_coords = world_invisible_tilemap.get_cell_atlas_coords(tile_pos)
	var tile_id = atlas_coords
	
	if tile_id in [Vector2i(2,0), Vector2i(2,1), Vector2i(3,0), Vector2i(3,1)]:
		var direction = ""
		match tile_id:
			Vector2i(2,0): direction = "north"
			Vector2i(2,1): direction = "south"
			Vector2i(3,0): direction = "east"
			Vector2i(3,1): direction = "west"
		
		print("Player entered %s door at room %s" % [direction, room_coord])
		
		var next_room = get_neighbor_position(room_coord, direction)
		if floor_layout.has(next_room):
			current_room_coord = next_room
			print("Now in room: %s" % next_room)
