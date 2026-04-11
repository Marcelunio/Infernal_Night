#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
class_name SingleFire  
extends RangedWeapon

func __shoot(spawn_pos: Vector2, entity):
	print("DEBUG - oddano strzal")
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
	bullet.global_position = spawn_pos+offset.rotated(rotation)
	var shoot_direction = Vector2.UP.rotated(entity.rotation)
	
	bullet.direction = shoot_direction
	bullet.shooter = entity
	bullet.weapon_origin = self
	
	get_tree().current_scene.add_child(bullet)
	
	
	#apply_impulse(shoot_direction * bullet_speed)
