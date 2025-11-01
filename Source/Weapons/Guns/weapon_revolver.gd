extends Weapon

func _ready():
	weapon_delay = 0.65
	super._ready()
	max_ammo = 6
	current_ammo =  6
	weapon_name = "revolwer"
	throw_force = 950
	weapon_damage = 3

func __shoot(spawn_pos: Vector2, player):
	print("DEBUG - oddano strzal")
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
	bullet.global_position = spawn_pos
	var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))
	
	bullet.direction = shoot_direction
	bullet.shooter = player
	bullet.weapon_origin = self
	
	get_tree().current_scene.add_child(bullet)
	
	
	#apply_impulse(shoot_direction * bullet_speed)
