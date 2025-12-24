#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
class_name MeleeWeapon extends Weapon

@export var melee_range: float 
@export var melee_angle: float 

var swing_sprite

func _ready():
	super._ready()
	swing_sprite = $SwingSprite.texture
	$SwingSprite.hide()

func __shoot(spawn_pos: Vector2, entity):
	var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn").instantiate()
		
	attack_area.global_position = spawn_pos
	attack_area.weapon_origin = self

	get_tree().current_scene.add_child(attack_area)
	attack_area.setup(melee_range, melee_angle, entity, swing_sprite)
	
