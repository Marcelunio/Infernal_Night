#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends PanelContainer

@export var ammo_icons: Array[Texture2D] = []

var inventory: Node = null
var ammo: Dictionary
@onready var v_box:Node = $VBoxContainer
@onready var label_list: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory = get_tree().get_first_node_in_group("player").get_node("InventoryMenager")
	ammo = inventory.ammo_container
	_build_ammo_list()
	inventory.UI_InventoryAmmoChanged.connect(_ammo_change_reloade)

func _build_ammo_list():
	var i = 0
	for ammo_type in ammo:
		var label = Label.new()
		var h_box = HBoxContainer.new()
		var texture = TextureRect.new()
	
		label_list.append(label)
		label.text = "%s: %d / %d" % [ammo_type, ammo[ammo_type]["current"], ammo[ammo_type]["max"]]
		texture.texture = ammo_icons[i]
		h_box.add_child(texture)
		h_box.add_child(label)
		v_box.add_child(h_box)
		i += 1

func _ammo_change_reloade() -> void:
	var keys = ammo.keys()
	for i in keys.size():
		var ammo_type = keys[i]
		var label = label_list[i]
		label.text = "%s: %d / %d" % [ammo_type, ammo[ammo_type]["current"], ammo[ammo_type]["max"]]
