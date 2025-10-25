#~~Kleks 20.10.2025
extends Weapon


func _ready():
	weapon_delay = 0.1
	super._ready()
	throw_force = 1250
	max_ammo = -1
	current_ammo = -1  
	weapon_name = "bat"

func __shoot(spawn_pos: Vector2, player):
	
	var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn")
	get_tree().current_scene.add_child(attack_area)
	attack_area.global_postion = spawn_pos

	
