#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control
#~~Kleks 19.10.2025
var current_weapon
func _ready():
	visible = false
	
func setup(inventory):
	inventory.UI_WeaponChanged.connect(_on_weapon_changed)

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

	
