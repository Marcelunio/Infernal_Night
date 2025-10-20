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
	
	#var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn")
	#get_tree().current_scene.add_child(attack_area)
	#attack_area.global_postion = spawn_pos
	
	#var bullet = preload("res://Scenes/bullet.tscn").instantiate()
	#get_tree().current_scene.add_child(bullet)
	#bullet.global_position = spawn_pos

	#var angle_offset = (randf_range(0,5) /2.0) * spread_angle
	#var angle_offset = randf_range(-current_spread, current_spread)
	#var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
	
	#current_spread += spread_increase
	#current_spread = min(current_spread, max_spread)   
	
	#bullet.direction = shoot_direction
	#bullet.shooter = player
	
