extends Weapon

#~~Kleks 19.10.2025
#fizyka strzelanie z shotguna
var spread_angle = 3.75
var bullet_count = 6

func _ready():
	super._ready()
	throw_force=800

func __shoot(spawn_pos: Vector2, player):
	
	for i in range(bullet_count):
		
		var bullet = preload("res://Scenes/bullet.tscn").instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = spawn_pos
		
		var angle_offset = (i - bullet_count / 2.0) * spread_angle
	
		var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
		bullet.direction = shoot_direction
		bullet.shooter = player
	
	
	#apply_impulse(shoot_direction * bullet_speed)
