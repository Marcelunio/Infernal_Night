extends Control
#~~Kleks 19.10.2025
var current_weapon
func _ready():
	visible = false
	
	var player = get_tree().get_first_node_in_group("player")#tu potrzebowalem pomocy wiadomo kogo generalnie inaczej nie dziala... bede potem probowal to naprawic

	if player == null:
		print("BŁĄD: Gracz nie ma grupy 'player'!")
		return
	
	player.UI_WeaponChanged.connect(_on_weapon_changed)

func _on_weapon_changed(weapon):
	if is_instance_valid(current_weapon):#dla <freed instance>
		if current_weapon is RangedWeapon and current_weapon != null:
			if current_weapon.UI_AmmoChanged.is_connected(_on_ammo_changed):
				current_weapon.UI_AmmoChanged.disconnect(_on_ammo_changed)
				
	if weapon == null:
		visible = false
	else:
		visible = true
		$VBoxContainer/WeaponSprite.texture = weapon.sprite
		
		
		
		
		current_weapon=weapon
	if weapon is RangedWeapon:
		$VBoxContainer/VBoxContainer/AmmoCounter.text = "%d / %d" % [weapon.current_ammo, weapon.max_ammo]
		weapon.UI_AmmoChanged.connect(_on_ammo_changed)
	else:
		$VBoxContainer/VBoxContainer/AmmoCounter.text = "%s" % ["white weapon"]
		
func _on_ammo_changed(current_ammo, max_ammo):
		$VBoxContainer/VBoxContainer/AmmoCounter.text = "%d / %d" % [current_ammo, max_ammo]#%int %int [zmienne]

	
