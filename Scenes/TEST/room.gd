extends Node2D

@onready var visible_tilemap = $Visual
@onready var invisible_tilemap = $Hidden

func merge_tilemaps_to(target_visible: TileMapLayer, target_invisible: TileMapLayer, offset: Vector2i):
	# Make sure tilemaps are initialized (in case _ready wasn't called)
	if visible_tilemap == null:
		visible_tilemap = get_node("Visual")
	if invisible_tilemap == null:
		invisible_tilemap = get_node("Hidden")
	
	merge_single_tilemap(visible_tilemap, target_visible, offset)
	merge_single_tilemap(invisible_tilemap, target_invisible, offset)

func merge_single_tilemap(source: TileMapLayer, target: TileMapLayer, offset: Vector2i):
	if source == null:
		push_error("Source tilemap is null!")
		return
	
	var used_cells = source.get_used_cells()
	
	for cell_pos in used_cells:
		var source_id = source.get_cell_source_id(cell_pos)
		var atlas_coords = source.get_cell_atlas_coords(cell_pos)
		var alternative_tile = source.get_cell_alternative_tile(cell_pos)
		
		var target_pos = cell_pos + offset
		target.set_cell(target_pos, source_id, atlas_coords, alternative_tile)
