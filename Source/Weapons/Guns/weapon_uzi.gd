#~~Kleks 31.10.2025
extends Weapon
#fizyka strzelanie z ak47
var spread_angle = 5.0        # Minimalny rozrzut
var max_spread = 20.0         # Maksymalny rozrzut
var spread_increase = 1.5     # O ile zwiększa się rozrzut przy każdym strzale
var current_spread = 2.0

func _ready():
	weapon_delay = 0.025
	super._ready()
	throw_force = 1000
	max_ammo = 32
	current_ammo = 32  
	weapon_name = "uzi"
	weapon_damage = 120

func __shoot(spawn_pos: Vector2, player):
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()

	bullet.global_position = spawn_pos
	var angle_offset = randf_range(-current_spread, current_spread)
	var shoot_direction = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
	
	bullet.direction = shoot_direction
	bullet.shooter = player
	bullet.weapon_origin = self 
	
	get_tree().current_scene.add_child(bullet)
	
	current_spread += spread_increase
	current_spread = min(current_spread, max_spread)
	
func spread_normalize():
	current_spread = 2.0
