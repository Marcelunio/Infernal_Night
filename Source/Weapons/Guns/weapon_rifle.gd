#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
class_name rifle
extends RangedWeapon

@export var spread_angle : float        # Minimalny rozrzut
@export var max_spread : float       # Maksymalny rozrzut
@export var spread_increase : float 
@export var base_spread : float   # O ile zwiększa się rozrzut przy każdym strzale
var current_spread = base_spread

#MG guns
@export var mg_familly: bool
@export var mg_starting_time: float 
@export var recoil_force: float
var shooting: bool = false


func __shoot(spawn_pos: Vector2, entity):
	if mg_familly and not shooting:
		shooting = true
		await get_tree().create_timer(mg_starting_time).timeout
	
	var bullet = preload("res://Scenes/Projectiles/bullet.tscn").instantiate()

	bullet.global_position = spawn_pos
	var angle_offset = randf_range(-current_spread, current_spread)
	var shoot_direction = Vector2.RIGHT.rotated(entity.rotation - deg_to_rad(90) + deg_to_rad(angle_offset))
	
	bullet.direction = shoot_direction
	bullet.shooter = entity
	bullet.weapon_origin = self 
	
	get_tree().current_scene.add_child(bullet)
	
	current_spread += spread_increase
	current_spread = min(current_spread, max_spread)
	
func spread_normalize():
	if mg_familly:
		shooting = false
		
	current_spread = base_spread
