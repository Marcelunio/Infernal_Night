extends Weapon

func _ready():
	weapon_delay = 0.65
	super._ready()
	max_ammo = 6
	current_ammo =  6
	weapon_name = "revolwer"
	throw_force = 950

func __shoot(spawn_pos: Vector2, player):
	
	
	print("DEBUG - oddano strzal")
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = spawn_pos
	
	var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))
	bullet.direction = shoot_direction
	bullet.shooter = player
	
	
	#apply_impulse(shoot_direction * bullet_speed)
