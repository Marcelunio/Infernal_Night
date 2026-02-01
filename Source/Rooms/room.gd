class_name Room
extends Node2D

signal room_entered
signal room_cleared

@onready var visible_layer: TileMapLayer = $LayerVisible
@onready var invisible_layer: TileMapLayer = $LayerInvisible

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

func spawn_enemies():
	enemies_spawned = true
	
	if invisible_layer == null:
		return
	
	var used_cells = invisible_layer.get_used_cells()
	
	for cell_pos in used_cells:
		var atlas_coords = invisible_layer.get_cell_atlas_coords(cell_pos)
		
		if atlas_coords == Vector2i(1, 1):
			var world_pos = invisible_layer.map_to_local(cell_pos)
			print("Enemy spawn at: ", world_pos)
			# TODO: instantiate enemy here

func clear_room():
	is_cleared = true
	emit_signal("room_cleared")
