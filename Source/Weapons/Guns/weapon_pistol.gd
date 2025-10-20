extends Weapon

func _ready():
	weapon_delay = 0.2
	super._ready()
	max_ammo = 17
	current_ammo =  17
	weapon_name = "pistol"
	throw_force = 1000

func __shoot(spawn_pos: Vector2, player):
	
	
	print("DEBUG - oddano strzal")
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = spawn_pos
	
	var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))
	bullet.direction = shoot_direction
	bullet.shooter = player
	
	
	#apply_impulse(shoot_direction * bullet_speed)
