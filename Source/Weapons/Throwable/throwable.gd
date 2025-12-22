class_name Throwable extends Weapon

@onready var pin_timer = get_node_or_null("PinTimer")

@export var explode_duration: Timer
@export var granade_familly: bool
@export var throwable_lethal: bool

var granate_pin:bool = true
var timer_started: bool = false

#reuse z melee weapon
@export var melee_range: float 
@export var melee_angle: float 

#enitty z enitity
var Entity
var explosion_sprite

signal exploded()

func _ready():
	super._ready()#musi byc zeby ready z weapon.gd sie odapalilo bo to ready nadpisuje tamto ~~Kekls
	if pin_timer:
		pin_timer.timeout.connect(explode)
		
	explosion_sprite = $ExplosionSprite.texture
	$ExplosionSprite.hide()
		
func __shoot(_spawn_pos: Vector2, entity) -> void:
	Entity = entity
	print("DEBUG: Throwable używa shoot tylko do przypisaia entity! Użyj throw() do wykonania akcji.")
	print(Entity)
	return
	
func pin():
	if !timer_started:
		print("TIMER START")
		timer_started = true
		pin_timer.start()
	
func explode():
	var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn").instantiate()
		
	attack_area.global_position = global_position
	attack_area.weapon_origin = self

	get_tree().current_scene.add_child(attack_area)
	attack_area.setup(melee_range, melee_angle, Entity, explosion_sprite, throwable_lethal)
	self.hide()
	emit_signal("exploded")
	
