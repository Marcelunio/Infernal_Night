#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Node

@onready var spinner = $Sprite2D

var next_scene_path: String = ""

func _ready():
	next_scene_path = GameState.next_scene
	spinner.modulate = Color.WHITE
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(delta):
	spinner.rotation += delta * 3.0
	
	var status = ResourceLoader.load_threaded_get_status(next_scene_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(scene)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Loading.gd - Błąd ładowania!")
