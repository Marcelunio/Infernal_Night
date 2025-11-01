extends Node2D

# --- Scene Nodes ---
@onready var room_container: Node2D = $RoomContainer
@onready var player: Node2D = $Player

# --- Settings ---
const ROOM_FOLDER_PATH: String = "res://Scenes/Rooms"
const ROOM_SPACING: Vector2 = Vector2(1024, 768)   # dystans między pokojami - dopasuj do rozmiaru pokoju
const MAX_ROOMS: int = 10                          # ile pokoi wygenerować

# --- Runtime Data ---
var room_scenes: Array[PackedScene] = []   # wszystkie wczytane prefabrykaty pokojów
var rooms := {}                            # Dictionary: Vector2(grid) -> room instance
var visited_positions: Array[Vector2] = [] # lista zajętych pozycji gridowych
var current_pos: Vector2 = Vector2.ZERO    # aktualna pozycja gridowa gracza

# -------------------------------------------------------------
# INIT
# -------------------------------------------------------------
func _ready() -> void:
	randomize()
	_load_room_scenes()
	generate_dungeon()
	player.global_position = rooms[Vector2(0,0)].global_position + (ROOM_SPACING / 2)

# -------------------------------------------------------------
# LOAD ALL ROOM SCENES FROM FOLDER
# -------------------------------------------------------------
func _load_room_scenes() -> void:
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

# -------------------------------------------------------------
# GENERATE DUNGEON LAYOUT
# -------------------------------------------------------------
func generate_dungeon() -> void:
	if room_scenes.is_empty():
		push_error("No room scenes loaded! Aborting generation.")
		return

	var start_pos: Vector2 = Vector2.ZERO
	_create_room(start_pos, "start")

	for i in range(MAX_ROOMS - 1):
		if visited_positions.is_empty():
			break
		var base_pos: Vector2 = visited_positions.pick_random()
		var next_pos: Vector2 = base_pos + _random_direction()
		if rooms.has(next_pos):
			continue
		_create_room(next_pos)

	print("Dungeon generated with rooms:", rooms.keys())

	# pokaż / załaduj startowy pokój (teraz funkcja istnieje)
	load_room(start_pos)

# -------------------------------------------------------------
# CREATE SINGLE ROOM
# -------------------------------------------------------------
func _create_room(grid_pos: Vector2, tag: String = "") -> void:
	var room_scene: PackedScene = room_scenes.pick_random()
	var room: Node2D = room_scene.instantiate()
	room_container.add_child(room)

	# Assign exported variable directly
	room.set("room_position", grid_pos)

	# Set position and visibility
	room.global_position = grid_pos * ROOM_SPACING

	# Connect door signal
	if room.has_signal("door_entered"):
		room.connect("door_entered", Callable(self, "_on_room_door_entered"))
	else:
		print("Warning: room at", grid_pos, "has no 'door_entered' signal")

	# Store in dictionary
	rooms[grid_pos] = room
	visited_positions.append(grid_pos)

	if tag == "start":
		current_pos = grid_pos


# -------------------------------------------------------------
# RANDOM DIRECTION HELPER (GRID)
# -------------------------------------------------------------
func _random_direction() -> Vector2:
	var dirs := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	return dirs.pick_random()

# -------------------------------------------------------------
# LOAD / SHOW ROOM (zmienia widoczność i ustawia gracza)
# -------------------------------------------------------------
func load_room(grid_pos: Vector2) -> void:
	if not rooms.has(grid_pos):
		push_error("load_room: no room at " + str(grid_pos))
		return

	# ustaw current_pos
	current_pos = grid_pos

	# teleport gracza w okolice środka pokoju (dostosuj wektor zależnie od rozmiaru)
	print("Loaded room at", grid_pos)

# -------------------------------------------------------------
# HANDLER: gdy pokój emituje, że gracz wszedł w drzwi
# sygnatura emitowana przez RoomBase: door_entered(direction:String, room_position:Vector2)
# -------------------------------------------------------------
func _on_room_door_entered(direction: String) -> void:
	var offset := Vector2.ZERO
	match direction:
		"up": offset = Vector2(0, -1)
		"down": offset = Vector2(0, 1)
		"left": offset = Vector2(-1, 0)
		"right": offset = Vector2(1, 0)

	var next_pos := current_pos + offset

	if not rooms.has(next_pos):
		print("No room in direction", direction, "from", current_pos)
		return

	current_pos = next_pos
	# player.global_position = rooms[next_pos].global_position + (ROOM_SPACING / 2)
	print("Moved player", direction, "to", next_pos)
