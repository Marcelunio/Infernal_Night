#~~Kleks 31.10.2025
extends Weapon

var melee_range: float = 100
var melee_angle: int = 60

func _ready():
	weapon_delay = 0.2
	super._ready()
	throw_force = 1250
	max_ammo = -1
	current_ammo = -1  
	weapon_name = "knife"

func __shoot(spawn_pos: Vector2, player):
	var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn").instantiate()
	get_tree().current_scene.add_child(attack_area)
	
	attack_area.global_position = spawn_pos

	attack_area.setup(melee_range, melee_angle, player)
