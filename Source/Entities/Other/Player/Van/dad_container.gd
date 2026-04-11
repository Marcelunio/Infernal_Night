extends PanelContainer

var texture: Texture2D
var weapon_name: String
var player_inventory: bool
var player: Node
var inventory: Node
var weapon: Node
var storage: Node
var from: String

func _ready() -> void:	
	pass
	
func _create() -> void:
	var style = StyleBoxTexture.new()
	style.texture = texture
	add_theme_stylebox_override("panel", style)

func _get_drag_data(at_position: Vector2) -> Variant:
	# co jest przeciągane
	if weapon_name.is_empty():
		return null
	var preview = TextureRect.new()
	preview.texture = texture
	set_drag_preview(preview)
	return {"name": weapon_name, "source": self}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return weapon_name.is_empty()

func _drop_data(at_position: Vector2, data: Variant) -> void:
	weapon_name = data["name"]
	texture = data["source"].texture
	weapon = data["source"].weapon
	_create()  
	
	if data["source"].player_inventory == true:
		from = "playerInventory"
	else:
		from = "vanInventory"
		
	
	data["source"].weapon_name = ""
	data["source"].texture = null
	data["source"].weapon = null
	data["source"]._create()
	if player_inventory and from == "vanInventory":
		inventory.add_weapon(weapon)
	elif from == "vanInventory":
		pass
	elif from == "playerInventory":
		inventory.remove_weapon(weapon, true)
		storage.add_child(weapon)
	else:
		print("DEBUG - SOMETHING WENT VERY WRONG IN dad_container.gd")
		
		
