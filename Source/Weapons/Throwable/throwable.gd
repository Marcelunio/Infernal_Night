#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
class_name Throwable extends Weapon

@onready var pin_timer = get_node_or_null("PinTimer")

@export var explode_duration: Timer
@export var granade_familly: bool
@export var throwable_lethal: bool

var granate_pin:bool = true
var timer_started: bool = false

#reuse z melee weapon
@export var radius: float 
@export var angle: float 

#enitty z enitity
var Entity: Node
var explosion_sprite

#HolyWater
var timer_wait_time
var after_explode: bool = false

signal exploded()

func _ready():
	super._ready()#musi byc zeby ready z weapon.gd sie odapalilo bo to ready nadpisuje tamto ~~Kekls
	if pin_timer:
		pin_timer.timeout.connect(explode)
	
	explosion_sprite = $ExplosionSprite.texture
	$ExplosionSprite.hide()
	
	if not granade_familly:
		timer_wait_time = pin_timer.wait_time

func _physics_process(_delta):
	if granade_familly or after_explode:
		return
	
	if linear_velocity.length_squared() < 90000 and is_thrown:
		explode()

func __shoot(_spawn_pos: Vector2, entity) -> void:
	print(entity)
	Entity = entity
	print("DEBUG: Throwable używa shoot tylko do przypisaia entity! Użyj throw() do wykonania akcji.")
	return
	
func pin():
	if !timer_started:
		print("TIMER START")
		timer_started = true
		pin_timer.start()
	
func explode():
	after_explode = true
	var attack_area = preload("res://Scenes/Projectiles/MeleeAttackCollision.tscn").instantiate()
		
	attack_area.global_position = global_position
	attack_area.weapon_origin = self
	get_tree().current_scene.add_child(attack_area)
	attack_area.setup(radius, angle, Entity, explosion_sprite, throwable_lethal)
	self.hide()
	emit_signal("exploded")
	
