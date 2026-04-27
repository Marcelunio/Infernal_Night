#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends CanvasLayer

var open: bool = false

const BOX = preload("res://Scenes/Entities/Other/ShopGuy/ShopBox.tscn")

const STAT_ITEMS = [
	["Speed UP", "Player moves 10% faster!", 10],
	["Health UP", "Player gets an additional health container!", 20],
	["9MM UP", "Player gets +10% more ammo capacity for 9mm ammo!", 10],
	["12gauge UP", "Player gets +10% more ammo capacity for 12gauge ammo!", 10],
	["5.56MM UP", "Player gets +10% more ammo capacity for 5.56mm ammo!", 10],
	["7.62MM UP", "Player gets +10% more ammo capacity for 7.62mm ammo!", 10],
	["Space inventory UP", "Player gets an additional slot in their weapon inventory!", 20],
	["Reload speed UP", "Player reload 10% faster!", 20]
]

const WEAPON_INFO = {
	"ak47" : ["Powerful machine gun rifle, excellent for showing true domination!", 15],
	"bat" : ["Thanks to your new shining bat you can feel like a true baseball player and leave your fans stunned!", 5],
	"doubleBarrel" : ["Now you can really start hunting!", 10],
	"holyGrenade" : ["Bombard your enemies with holy light!", 8],
	"HolyWater" : ["Baptise your enemies with a little violence!", 8],
	"knife" : ["Silent and deadly. Gets the job done up close and personal.", 10],
	"pistol" : ["Classic, reliable, never lets you down. Sometimes that's all you need!", 5],
	"revolver" : ["With it you can give your enemies old heavy western punch!", 10],
	"scar" : ["Great firepower, great looks, everything is great about this rifle!", 15],
	"shotgun" : ["Just watch them run with fear!", 10],
	"uzi" : ["If you feeling a little gangsta today, then show them who is the boss here!", 15]
}

var WEAPONS:Array[String]

@export var STAT_ICONS: Array[Texture2D]

@onready var h_box = $PanelContainer/MarginContainer/HBoxContainer

@export var sold_out: Texture2D

var player: Node
var inventory: Node

func _ready() -> void:
	seed(PlayerData.dungeon_seed)
	h_box.alignment = HBoxContainer.ALIGNMENT_CENTER
	open = false
	visible = false
	
	var pliki_weapons = DirAccess.get_files_at("res://Scenes/Weapons/")
	
	for plik in pliki_weapons:
		if plik.ends_with(".tscn"):  # filtruj
			WEAPONS.append(plik)
			
	call_deferred("connect_signals")

func connect_signals() -> void:
	player =  get_tree().get_first_node_in_group("player")
	inventory = player.get_node("InventoryMenager")
	create_shop()

func create_shop():
	
	for i in range(3):
		var box = BOX.instantiate()
		var v_box = VBoxContainer.new()
		var text_rect = TextureRect.new()
		var label = Label.new()
		
		var typ: int
		if i == 0:
			typ = 0
		elif i == 1:
			typ = 1
		else:
			typ = randi() % 2
		
		
		var cena: int
		var weapon_name
		var index = randi() % STAT_ITEMS.size()
		
		if typ == 0:
			var x = load("res://Scenes/Weapons/" + WEAPONS.pick_random())
			x = x.instantiate()
			weapon_name = x.weapon_name
			cena = WEAPON_INFO[weapon_name][1]
			box.tooltip_text = WEAPON_INFO[weapon_name][0]
			text_rect.texture = x.sprite
			label.text = GameState.to_pascal_case(weapon_name) + "\nPrice: " + str(cena)
			x.queue_free()
		
		if typ == 1:
			cena = STAT_ITEMS[index][2]
			box.tooltip_text = STAT_ITEMS[index][1]
			text_rect.texture = STAT_ICONS[index]
			label.text = STAT_ITEMS[index][0] + "\nPrice: " + str(cena)
		
		var kupiono = [false]#Zeby mozna bylpo przypisac bo labda nie pozwala na zmiennych ale... tablica zawsze dziaal jako refernecja xD

		box.gui_input.connect(func(event):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					if kupiono[0]:
						return
					if inventory.coins >= cena:
						kupiono[0] = true
						_on_purchase(typ, weapon_name, index, cena, box, label, text_rect)
		)
		
		v_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 32)
		
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		text_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		text_rect.custom_minimum_size = Vector2(0, 150)
		
		
		v_box.add_child(text_rect)
		v_box.add_child(label)
		box.add_child(v_box)
		h_box.add_child(box)

func _on_purchase(typ: int, weapon_name, index: int, cena: int, box: PanelContainer, label: Label, text_rect: TextureRect):
	inventory.coins -= cena
	inventory.emit_signal("UI_InventoryCoinChanged")
	
	if typ == 0:
		var bron = load("res://Scenes/Weapons/Weapon" + GameState.to_pascal_case(weapon_name) + ".tscn").instantiate()
		bron.position = get_tree().current_scene.get_node("Palette").position
		get_tree().current_scene.add_child(bron)
	
	if typ == 1:
		match index:
			0:
				PlayerData.speed *= 1.1
				player.speed *= 1.1
			1:
				PlayerData.max_hp += 2
				player.max_hp += 2
			2:
				PlayerData.ammo_container["9mm"]["max"] = roundi(PlayerData.ammo_container["9mm"]["max"] * 1.1)
				inventory.ammo_container["9mm"]["max"] = roundi(inventory.ammo_container["9mm"]["max"] * 1.1)
			3:
				PlayerData.ammo_container["12gauge"]["max"] = roundi(PlayerData.ammo_container["12gauge"]["max"] * 1.1)
				inventory.ammo_container["12gauge"]["max"] = roundi(inventory.ammo_container["12gauge"]["max"] * 1.1)
			4:
				PlayerData.ammo_container["5.56mm"]["max"] = roundi(PlayerData.ammo_container["5.56mm"]["max"] * 1.1)
				inventory.ammo_container["5.56mm"]["max"] = roundi(inventory.ammo_container["5.56mm"]["max"] * 1.1)
			5:
				PlayerData.ammo_container["7.62mm"]["max"] = roundi(PlayerData.ammo_container["7.62mm"]["max"] * 1.1)
				inventory.ammo_container["7.62mm"]["max"] = roundi(inventory.ammo_container["7.62mm"]["max"] * 1.1)
			6:
				PlayerData.inventory_size += 1
				inventory.weapon_container_capacity += 1
				get_tree().get_first_node_in_group("VanStorage").get_parent()._add_player_container()
			7:
				PlayerData.reload_speed_multiplier *= 0.9
		
		inventory.emit_signal("UI_InventoryAmmoChanged")
		player.emit_signal("UI_HealthBarDisplay", player.max_hp, player.hp)
		get_tree().get_first_node_in_group("VanStorage").get_parent()._refresh_player_inventory()
	
	label.text = "SOLD OUT"
	text_rect.texture = sold_out
	box.tooltip_text = "It is sold out..."


func _open() -> void:
	visible = true
	open = true
	#_refresh_player_inventory()

func _close() -> void:
	visible = false
	open = false
