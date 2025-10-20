extends Node2D

@onready var room_container = $RoomContainer
@onready var player = $Player

var room_folder_path = "res://Scenes/Rooms"
var room_scenes: Array[PackedScene] = []

func _ready():
	load_room_scenes()
	#generate_dungeon()

func load_room_scenes():
	var dir := DirAccess.open(room_folder_path)
	if dir == null:
		push_error("Could not open folder: " + room_folder_path)
		return
	
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			var full_path = room_folder_path + "/" + file_name
			var scene = load(full_path)
			if scene is PackedScene:
				room_scenes.append(scene)
				print("Loaded room scene :", full_path)
