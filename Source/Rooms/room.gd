class_name Room
extends Node2D

signal room_entered
signal room_cleared

@onready var visible_layer: TileMapLayer = $NavigationRegion2D/LayerVisible
@onready var invisible_layer: TileMapLayer = $LayerInvisible

const ENEMY: PackedScene = preload("res://Scenes/Entities/Enemies/GhostFraction/Ghost/Ghost.tscn")

var grid_position: Vector2i = Vector2i.ZERO
var is_cleared: bool = false
var enemies_spawned: bool = false

func setup(pos: Vector2i):
	grid_position = pos

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
	
	if invisible_layer == null:
		return
	
	var used_cells = invisible_layer.get_used_cells()
	var spawned_enemies: Array = []  # Track spawned enemies
	
	for cell_pos in used_cells:
		var atlas_coords = invisible_layer.get_cell_atlas_coords(cell_pos)
		
		if atlas_coords == Vector2i(1, 1):
			var world_pos = invisible_layer.map_to_local(cell_pos)
			
			var enemy_instance = ENEMY.instantiate()
			add_child(enemy_instance)
			enemy_instance.position = world_pos
			enemy_instance.frozen = true
			spawned_enemies.append(enemy_instance)
	
	await get_tree().create_timer(1.5).timeout
	
	for enemy in spawned_enemies:
		if is_instance_valid(enemy) and enemy.is_inside_tree():
			enemy.frozen = false

func clear_room():
	is_cleared = true
	emit_signal("room_cleared")
