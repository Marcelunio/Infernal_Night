#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Area2D

@export var ammo_type: String = ""
@export var ammo_count: int
@export var textures: Array[Texture2D] = []

var current_textures: Array[Texture2D] = []
var max_ammo_count: int

func _ready() -> void:#connect body_entered|exited
	current_textures.append(textures[0])
	current_textures.append(textures[1])
	$Sprite2D.texture = current_textures[0]
	call_deferred("_connect_signals")
	max_ammo_count = ammo_count

func _connect_signals() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var inventory = player.get_node("InventoryMenager")
	inventory.UI_NearestItemChanged.connect(_closest_to_player)

func _closest_to_player(item, closest):
	if item == self:
		if closest:
			$Sprite2D.texture = current_textures[1]
		else:
			$Sprite2D.texture = current_textures[0]

func _on_body_entered(body) -> void:#check
	if body.name == "Player":
		body.inventory.is_ammo_full(self)

func _on_body_exited(body) -> void:#uncheck
	if body.name == "Player":
		body.inventory.ammo_exit(self)

func ammo_pick_up(body) -> void:#ammo pick_up
	var inv = body.inventory
	var needed = inv.ammo_container[ammo_type]["max"] - inv.ammo_container[ammo_type]["current"]
	
	if ammo_count - needed <= 0:
		inv.ammo_container[ammo_type]["current"] += ammo_count
		inv.emit_signal("UI_InventoryAmmoChanged")
		die()
		return
	else:
		inv.ammo_container[ammo_type]["current"] += needed
		inv.emit_signal("UI_InventoryAmmoChanged")
		ammo_count -= needed
		
	sprite_change()

func sprite_change() -> void:#change of sprite:
	var ammo_percentage = float(ammo_count) / max_ammo_count
		
	if ammo_percentage < 0.2:
		current_textures[0] = textures[2]
		current_textures[1] = textures[3]
	elif ammo_percentage < 0.5:
		current_textures[0] = textures[4]
		current_textures[1] = textures[5]

func die():#delete
	print("DEBUG ammo.gd | Ammo sie skonczylo w ", self.name)
	queue_free()
	
