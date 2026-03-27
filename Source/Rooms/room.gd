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

func setup(pos: Vector2i):
	grid_position = pos
	print(get_path())

func enter_room():
	visible = true
	emit_signal("room_entered")
	
	if not enemies_spawned:
		spawn_enemies()

func exit_room():
	visible = false
	
	for child in get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
	
	enemies_spawned = false

func spawn_enemies():
	enemies_spawned = true
	enemy_counter = 0
	
	var spawn_markers = get_node_or_null("EnemySpawns")
	if spawn_markers == null:
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
	
	
	
	emit_signal("room_cleared")

func on_enemy_died():
	enemy_counter -= 1
	if enemy_counter == 0:
		clear_room()
