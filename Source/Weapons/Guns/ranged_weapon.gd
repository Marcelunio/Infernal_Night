#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
@abstract
class_name RangedWeapon
extends Weapon


@export var bullet_speed: float = 1500

#signal to ammo_display.gd
signal UI_AmmoChanged(current_ammo, max_ammo)
#signal to inventory_menager.gd
signal reloaded(weapon, amount)

func shoot(spawn_pos: Vector2, entity):
	
	if(current_ammo<1):
		return
	if(super.shoot(spawn_pos,entity)):
		current_ammo-=1
		emit_signal("UI_AmmoChanged",current_ammo, max_ammo)

func _reload(amount_in_inventory):
	await get_tree().create_timer(reload_time).timeout
	var amount_reloaded
	if self.is_in_group("weapon-shotguns"):
		current_ammo += 1
		emit_signal("reloaded", self, 1)
	else:
		if amount_in_inventory >= max_ammo - current_ammo:
			amount_reloaded = max_ammo - current_ammo
			current_ammo = max_ammo
			emit_signal("reloaded", self, amount_reloaded)
		else:
			current_ammo = current_ammo + amount_in_inventory
			emit_signal("reloaded", self, amount_in_inventory)
	
	emit_signal("UI_AmmoChanged",current_ammo, max_ammo)
	print("doszl do emit")	
