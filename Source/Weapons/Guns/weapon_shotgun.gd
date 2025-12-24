#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends RangedWeapon

#~~Kleks 19.10.2025
#fizyka strzelanie z shotguna
@export var spread_angle : float
@export var bullet_count : int



func __shoot(spawn_pos: Vector2, player):
	
	for i in range(bullet_count):
		
		var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
		
		bullet.global_position = spawn_pos
		
		var angle_offset
		if i < 3:
			angle_offset =  randf_range(-0.2*spread_angle,0.2*spread_angle)
		elif i < 5:
			angle_offset = randf_range(-0.5*spread_angle, 0.5*spread_angle)
		else:
			angle_offset = randf_range(-spread_angle,spread_angle)
	
		var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
		bullet.direction = shoot_direction
		bullet.shooter = player
		bullet.weapon_origin = self
		
		get_tree().current_scene.add_child(bullet)
	
	
	#apply_impulse(shoot_direction * bullet_speed)
