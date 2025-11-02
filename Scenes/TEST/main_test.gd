extends Node2D

const ROOM_FOLDER_PATH: String = "res://Scenes/TEST"

var room_scenes: Array[PackedScene] = []   # wszystkie wczytane prefabrykaty pokojów
var rooms := {}                            # Dictionary: Vector2(grid) -> room instance
var current_pos: Vector2 = Vector2.ZERO    # aktualna pozycja gridowa gracza

func _ready() -> void:
	randomize()
	_load_room_scenes()

func _load_room_scenes() -> void:
	var dir := DirAccess.open(ROOM_FOLDER_PATH)
	if dir == null:
		push_error("Could not open room folder: " + ROOM_FOLDER_PATH)
		return

	for file_name in dir.get_files():
		if file_name.ends_with(".tscn") and file_name.begins_with("Room"):
			var full_path := ROOM_FOLDER_PATH + "/" + file_name
			var scene = load(full_path)
			if scene is PackedScene:
				room_scenes.append(scene)
				print("Loaded room scene:", full_path)

	if room_scenes.is_empty():
		push_error("No room scenes found in " + ROOM_FOLDER_PATH)
