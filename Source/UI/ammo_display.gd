extends Control
#~~Kleks 19.10.2025

func _ready():
	visible = false
	
	var player = get_tree().get_first_node_in_group("player")#tu potrzebowalem pomocy wiadomo kogo generalnie inaczej nie dziala... bede potem probowal to naprawic
	
	if player == null:
		print("BŁĄD: Gracz nie ma grupy 'player'!")
		return
	
	player.UI_WeaponChanged.connect(_on_weapon_changed)
	player.UI_AmmoChanged.connect(_on_ammo_changed)

func _on_weapon_changed(weapon):
	if weapon == null:
		visible = false
	else:
		visible = true
		$VBoxContainer/WeaponSprite.texture = weapon.sprite

func _on_ammo_changed(current_ammo, max_ammo):
	$VBoxContainer/VBoxContainer/AmmoCounter.text = "%d / %d" % [current_ammo, max_ammo]#%int %int [zmienne]
