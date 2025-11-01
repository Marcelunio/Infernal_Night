extends Weapon

#~~Kleks 31.10.2025
#fizyka strzelanie z shotguna
var spread_angle = 0.9375
var bullet_count = 24

func _ready():
	weapon_delay = 1
	super._ready()
	throw_force=600
	max_ammo = 2
	current_ammo =  2
	weapon_name = "DoubleBarrel"
	weapon_damage = 0.7

func __shoot(spawn_pos: Vector2, player):
	
	for i in range(bullet_count):
		
		var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
		
		bullet.global_position = spawn_pos
		
		var angle_offset
		if i < 3:
			angle_offset =  randf_range(-5.625, 5.625)
		elif i < 5:
			angle_offset = randf_range(-16.875, 16.875)
		else:
			angle_offset = randf_range(-22.5, 22.5)
	
		var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
		bullet.direction = shoot_direction
		bullet.shooter = player
		bullet.weapon_origin = self
		
		get_tree().current_scene.add_child(bullet)
	
	
	#apply_impulse(shoot_direction * bullet_speed)
