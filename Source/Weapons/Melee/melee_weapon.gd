class_name MeleeWeapon extends Weapon

@export var melee_range: float 
@export var melee_angle: float 


func __shoot(spawn_pos: Vector2, player):
	var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn").instantiate()
		
	attack_area.global_position = spawn_pos
	attack_area.weapon_origin = self

	get_tree().current_scene.add_child(attack_area)
	attack_area.setup(melee_range, melee_angle, player)
	
