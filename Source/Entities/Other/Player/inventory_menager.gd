#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Node2D

#invetnory capacity
@export var weapon_container_capacity: int = 3
var weapon_container: Array[Node] = []

#weapon holding
var current_weapon: Node = null
var selected_weapon: int = 0

#weapon picking
var pick_up_check : bool = false
var nearest_weapon: Node = null

#weapon NODE container
@onready var NODE_weapon_container = $WeaponContainer

#weapon reloading
var reload_pending: bool = false
@export var max_9mm: int
@export var max_5_56mm: int
@export var max_12gauge: int
@export var max_7_62mm: int
var ammo_container: Dictionary 
var ammo_pick_up_check: bool = false
var nearest_ammo: Node = null

#signal to ammo_display.gd
signal UI_WeaponChanged(weapon)

func _ready() -> void:
	ammo_container = {
	"9mm": {"current": max_9mm, "max": max_9mm},             # Pistolety, SMG (UZI, MP5, Glock)
	"5.56mm": {"current": max_5_56mm, "max": max_5_56mm},    # Karabiny szturmowe (M16, AK-47, M4)
	"12gauge": {"current": max_12gauge, "max": max_12gauge}, # Shotguny
	"7.62mm": {"current": max_7_62mm, "max": max_7_62mm}     # Snajperki, heavy MG
	}
	debug_print_ammo()

func next_weapon():#player.gd _unhandled_input()
	selected_weapon = (selected_weapon + 1) % weapon_container.size()
	change_weapon(selected_weapon)

func previous_weapon():#player.gd _unhandled_input()
	selected_weapon = (selected_weapon - 1 + weapon_container.size()) % weapon_container.size()
	change_weapon(selected_weapon)	

func is_full(weapon):#weapon.gd _on_body_entered()
	if weapon_container.size() >= weapon_container_capacity:
		pick_up_check = false
	else:
		pick_up_check = true 
		nearest_weapon = weapon

func body_exit(weapon):#weapon.gd _on_body_exited()
	if nearest_weapon == weapon:
		pick_up_check = false
		nearest_weapon = null

func add_weapon(weapon):#weapon.gd pick_up()
	if weapon_container.size() >= weapon_container_capacity:
		return false
		
	weapon_container.append(weapon)	
		
	if weapon.is_in_group("weapon-throwable"):
		weapon.exploded.connect(_on_weapon_exploded_in_hand.bind(weapon))
		
	current_weapon = weapon
	selected_weapon = weapon_container.size() - 1
	emit_signal("UI_WeaponChanged", current_weapon)
	
	# Użyj reparent - robi remove + add automatycznie!
	weapon.reparent(NODE_weapon_container)
	
	return true

func throw(velocity: Vector2, weapon):#player.gd _handle_weapon_action()
	if weapon_container.is_empty():
		return
	
	if weapon.is_in_group("weapon-throwable"):
		weapon.shoot(get_parent().global_position, get_parent())#to jest uzywane tylko do przypisania entity
		if weapon.is_in_group("weapon-throwable-granate") and weapon.granate_pin:
			weapon.pin()
			weapon.granate_pin = false
			return
	
	if weapon.is_in_group("weapon-throwable") and weapon.exploded.is_connected(_on_weapon_exploded_in_hand):
		weapon.exploded.disconnect(_on_weapon_exploded_in_hand)
	
	weapon_container.remove_at(selected_weapon)
	weapon_container_ui_update()
	
	# Przenieś broń z powrotem do świata
	weapon.reparent(get_tree().current_scene)
	
	weapon.throw(get_parent().global_position, velocity)

func weapon_container_ui_update():#Uaktualnia UI z bronia oraz ammo
	
	if selected_weapon >= weapon_container.size():
		selected_weapon = weapon_container.size() - 1
	
	if not weapon_container.is_empty():
		change_weapon(selected_weapon)
	else:
		selected_weapon = 0
		current_weapon = null
		emit_signal("UI_WeaponChanged", null)

func change_weapon(select) -> void:#zmiana broni
	current_weapon = weapon_container[select]
	emit_signal("UI_WeaponChanged", current_weapon)

func reload(weapon) -> void:#przeladowanie broni
	if weapon.current_ammo == weapon.max_ammo:
		return
	
	if reload_pending:
		return
	else:
		reload_pending = true

	print("doszl do emit")	
	if not weapon.has_method("_reload"):
		push_error("weapon.gd reload(): Tego nie powinienes widziec. jezeli to widzisz w debugerze to ktoras bron ktora nie powinna miec opcji zaladunku wywolala metode reload()")
		return

	if ammo_container[weapon.weapon_ammo_type]["current"] > 0:
		weapon._reload(ammo_container[weapon.weapon_ammo_type]["current"])
		weapon.reloaded.connect(_on_reload)
	else:
		print("DEBUG - brak ammo")
		return

func is_ammo_full(ammo_box) -> void:
	if ammo_container[ammo_box.ammo_type]["current"] == ammo_container[ammo_box.ammo_type]["max"]:
		ammo_pick_up_check = false
	else:
		ammo_pick_up_check = true
		nearest_ammo = ammo_box

func ammo_exit(ammo_box) -> void:
	if nearest_ammo == ammo_box:
		nearest_ammo = null
		ammo_pick_up_check = false

func debug_print_ammo() -> void:
	print("=== AMMO DEBUG ===")
	for ammo_type in ammo_container.keys():
		var ammo = ammo_container[ammo_type]
		print(
			ammo_type, ": ",
			ammo["current"], " / ", ammo["max"]
		)
	print("==================")

#=========obsługa sygnałów=========:

func _on_weapon_exploded_in_hand(weapon):#specjalny przypadek do obslugi nie typowych zachowan granatow
	var index = weapon_container.find(weapon)
	
	if index != -1:
		weapon_container.remove_at(index)
	
	var node_weapon_container = weapon.get_parent()
	node_weapon_container.remove_child(weapon)
	
	weapon_container_ui_update()

func _on_reload(weapon, amount) -> void:#zabiera amunicje
	print("reload finish")
	ammo_container[weapon.weapon_ammo_type]["current"] = ammo_container[weapon.weapon_ammo_type]["current"] - amount
	reload_pending = false
	
	if weapon.reloaded.is_connected(_on_reload):
		weapon.reloaded.disconnect(_on_reload)
		
	print(ammo_container[weapon.weapon_ammo_type]["current"])
