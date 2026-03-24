extends Control

const ROOM_SIZE: Vector2 = Vector2(40, 40)
const ROOM_GAP: float = 8.0
const DOOR_THICKNESS: float = 6.0

const COLOR_UNVISITED = Color(0.16, 0.16, 0.16)
const COLOR_VISITED = Color.WHITE
const COLOR_CURRENT = Color(0.25, 0.66, 1.0)
const COLOR_PLAYER = Color.GREEN
const COLOR_DOOR = Color(0.5, 0.5, 0.5)

var dungeon: Node2D
var room_rects := {}
var player_marker: ColorRect

func _ready():
	print("Minimap ready!")
	
	dungeon = get_node("/root/Main/Dungeon")
	
	dungeon.floor_generated.connect(create_minimap)
	dungeon.room_changed.connect(update_player_position)

func create_minimap():
	print("=== MINIMAP DEBUG ===")
	print("Dungeon: ", dungeon)
	print("Room positions: ", dungeon.room_positions)
	print("Room count: ", dungeon.room_positions.size())
	
	var center_offset = calculate_center_offset()
	print("Center offset: ", center_offset)
	
	for room_pos in dungeon.room_positions:
		var room_rect = create_room_square(room_pos, center_offset)
		print("Created room at: ", room_rect.position, " size: ", room_rect.size)
		room_rects[room_pos] = room_rect
		add_child(room_rect)
		add_door_indicators(room_rect, room_pos)
	
	create_player_marker(center_offset)
	print("Player marker at: ", player_marker.position)
	print("=== END DEBUG ===")
	
	center_on_room(Vector2i.ZERO)
	visit_room(Vector2i.ZERO)

func center_on_room(room_pos: Vector2i):
	if not room_rects.has(room_pos):
		return
	
	var room_rect = room_rects[room_pos]
	var minimap_center = size / 2
	var offset = minimap_center - (room_rect.position + ROOM_SIZE / 2)
	
	for rect in room_rects.values():
		rect.position += offset
	
	player_marker.position += offset

func calculate_center_offset() -> Vector2:
	var min_pos := Vector2i(9999, 9999)
	var max_pos := Vector2i(-9999, -9999)
	
	for room_pos in dungeon.room_positions:
		min_pos.x = mini(min_pos.x, room_pos.x)
		min_pos.y = mini(min_pos.y, room_pos.y)
		max_pos.x = maxi(max_pos.x, room_pos.x)
		max_pos.y = maxi(max_pos.y, room_pos.y)
	
	return -Vector2(min_pos) * (ROOM_SIZE + Vector2(ROOM_GAP, ROOM_GAP))

func create_room_square(room_pos: Vector2i, center_offset: Vector2) -> ColorRect:
	var room_rect = ColorRect.new()
	room_rect.size = ROOM_SIZE
	
	var map_pos = Vector2(room_pos) * (ROOM_SIZE + Vector2(ROOM_GAP, ROOM_GAP))
	room_rect.position = map_pos + center_offset
	room_rect.color = COLOR_UNVISITED
	
	return room_rect

func add_door_indicators(room_rect: ColorRect, room_pos: Vector2i):
	if dungeon.room_positions.has(room_pos + Vector2i.UP):
		var door = ColorRect.new()
		door.size = Vector2(12, DOOR_THICKNESS)
		door.position = Vector2(14, -DOOR_THICKNESS)
		door.color = COLOR_DOOR
		room_rect.add_child(door)
	
	if dungeon.room_positions.has(room_pos + Vector2i.DOWN):
		var door = ColorRect.new()
		door.size = Vector2(12, DOOR_THICKNESS)
		door.position = Vector2(14, ROOM_SIZE.y)
		door.color = COLOR_DOOR
		room_rect.add_child(door)
	
	if dungeon.room_positions.has(room_pos + Vector2i.LEFT):
		var door = ColorRect.new()
		door.size = Vector2(DOOR_THICKNESS, 12)
		door.position = Vector2(-DOOR_THICKNESS, 14)
		door.color = COLOR_DOOR
		room_rect.add_child(door)
	
	if dungeon.room_positions.has(room_pos + Vector2i.RIGHT):
		var door = ColorRect.new()
		door.size = Vector2(DOOR_THICKNESS, 12)
		door.position = Vector2(ROOM_SIZE.x, 14)
		door.color = COLOR_DOOR
		room_rect.add_child(door)

func create_player_marker(center_offset: Vector2):
	player_marker = ColorRect.new()
	player_marker.size = Vector2(12, 12)
	player_marker.color = COLOR_PLAYER
	
	var start_pos = center_offset + (ROOM_SIZE / 2) - Vector2(6, 6)
	player_marker.position = start_pos
	
	add_child(player_marker)

func update_player_position(room_pos: Vector2i):
	visit_room(room_pos)
	
	if room_rects.has(room_pos):
		var room_rect = room_rects[room_pos]
		var center = room_rect.position + (ROOM_SIZE / 2) - Vector2(6, 6)
		player_marker.position = center
		center_on_room(room_pos)

func visit_room(room_pos: Vector2i):
	for pos in room_rects:
		if pos == room_pos:
			room_rects[pos].color = COLOR_CURRENT
		elif dungeon.visited_rooms.has(pos):
			room_rects[pos].color = COLOR_VISITED
		else:
			room_rects[pos].color = COLOR_UNVISITED
