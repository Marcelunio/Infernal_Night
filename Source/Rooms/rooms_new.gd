# ja to zrobiłem

extends Node2D

const ROOM_FOLDER_PATH: String = "res://Scenes/Floors/ValidRooms"
const MAX_ROOMS: int = 10
const PLAYER: PackedScene = preload("res://Scenes/Entities/Other/Player/Player.tscn")

var room_scenes: Array[PackedScene] = []
var room_map := {}

func _ready():
	randomize()
	preload_rooms()
	generate_floor()

func _process(delta: float):
	pass

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
	room_map[Vector2i(0,0)] = room_scenes[0]
	
	
