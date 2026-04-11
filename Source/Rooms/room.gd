class_name Room
extends Node2D

signal room_entered
signal room_cleared

@onready var room_layout: TileMapLayer = $NavigationRegion2D/RoomLayout

const ENEMY: PackedScene = preload("res://Scenes/Entities/Enemies/Ghost/Ghost.tscn")

var grid_position: Vector2i = Vector2i.ZERO
var is_cleared: bool = false
var enemies_spawned: bool = false
var enemy_counter: int = 0
var doors: Dictionary = {}

#SFX
@onready var audio_player_door: AudioStreamPlayer = $Sounds/Door
@export var door_sounds: Array[AudioStream] = []

func _ready() -> void:
	# Build doors dict from whichever door nodes actually exist
	var door_map = {
		"up": "DoorUp",
		"down": "DoorDown",
		"left": "DoorLeft",
		"right": "DoorRight"
	}
	for key in door_map:
		var node = get_node_or_null(door_map[key])
		if node != null:
			doors[key] = node

func setup(pos: Vector2i):
	grid_position = pos
	print(get_path())

func enter_room():
	visible = true
	emit_signal("room_entered")
	if not is_cleared:
		spawn_enemies()
		if not is_cleared:
			for door in doors.values():
				door.set_collision_mask_value(1, true)
				door.get_child(0).play("close")
				if not audio_player_door.playing:
					audio_player_door.stream = door_sounds.pick_random()
					audio_player_door.play()

func exit_room():
	visible = false

func spawn_enemies():
	enemies_spawned = true
	enemy_counter = 0
	
	var spawn_markers = get_node_or_null("EnemySpawns")
	
	if spawn_markers == null or spawn_markers.get_child_count() == 0:
		is_cleared = true
		for door in doors.values():
			door.set_collision_mask_value(1, false)
		emit_signal("room_cleared")
		return
	
	var spawned_enemies: Array = []
	
	for marker in spawn_markers.get_children():
		if marker is Marker2D:
			enemy_counter += 1
			var enemy_instance = ENEMY.instantiate()
			add_child(enemy_instance)
			enemy_instance.position = marker.position
			enemy_instance.frozen = true
			spawned_enemies.append(enemy_instance)
			enemy_instance.enemy_died.connect(on_enemy_died)
	
	await get_tree().create_timer(1.5).timeout
	
	for enemy in spawned_enemies:
		if is_instance_valid(enemy) and enemy.is_inside_tree():
			enemy.frozen = false

func clear_room():
	is_cleared = true
	for door in doors.values():
		door.set_collision_mask_value(1, false)
		door.get_child(0).play("open")
		
	if not audio_player_door.playing:
		audio_player_door.stream = door_sounds.pick_random()
		audio_player_door.play()
	emit_signal("room_cleared")

func on_enemy_died():
	enemy_counter -= 1
	print(enemy_counter)
	if enemy_counter == 0:
		clear_room()
