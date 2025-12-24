#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
@abstract
class_name RangedWeapon extends Weapon

@export var max_ammo: int
@onready var current_ammo: int = max_ammo
@export var bullet_speed: float = 1500

signal UI_AmmoChanged(current_ammo, max_ammo)

func shoot(spawn_pos: Vector2, entity):
	
	if(current_ammo<1):
		return
	if(super.shoot(spawn_pos,entity)):
		current_ammo-=1
		emit_signal("UI_AmmoChanged",current_ammo, max_ammo)
