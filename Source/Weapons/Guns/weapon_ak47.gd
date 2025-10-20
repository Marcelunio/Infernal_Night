#~~Kleks 19.10.2025
extends Weapon
#fizyka strzelanie z ak47
var spread_angle = 2.0        # Minimalny rozrzut
var max_spread = 15.0         # Maksymalny rozrzut
var spread_increase = 0.75     # O ile zwiększa się rozrzut przy każdym strzale
var current_spread = 2.0

func _ready():
	weapon_delay = 0.1
	super._ready()
	throw_force = 900
	max_ammo = 30
	current_ammo = 30  
	weapon_name = "ak47"

func __shoot(spawn_pos: Vector2, player):
	
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = spawn_pos

	#var angle_offset = (randf_range(0,5) /2.0) * spread_angle
	var angle_offset = randf_range(-current_spread, current_spread)
	var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
	
	current_spread += spread_increase
	current_spread = min(current_spread, max_spread)   
	
	bullet.direction = shoot_direction
	bullet.shooter = player
	
func spread_normalize():
	current_spread = 2.0
