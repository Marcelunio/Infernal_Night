#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Area2D

#Ogole
var weapon_origin: Node = null
var damage: int
var radius: float
var angle: float
var entity: Node

#Melee
var stun_timer :float

#Throwable
var throwable_lethal: bool

#Throwable non granade
var acid_check: bool = true

func _ready() -> void:
	if weapon_origin:
		damage = weapon_origin.weapon_damage
		
		if weapon_origin.is_in_group("weapon-throwable-nongranate"):
			await get_tree().create_timer(weapon_origin.timer_wait_time).timeout
			acid_check = false
		
		if damage == 0:
			stun_timer = 5
		else:
			stun_timer = 1.2
	else:
		print("DEBUG - weapon_origin jest null!")

func _physics_process(_delta: float) -> void:
	if not weapon_origin.is_in_group("weapon-throwable-nongranate"):
		return
	
	if acid_check:
		check_bodies()
	else:
		queue_free()

func setup(setup_radius, setup_angle, setup_entity, effect_sprite, setup_throwable_lethal:bool = false) -> void:
	radius = setup_radius
	angle = setup_angle
	entity = setup_entity
	throwable_lethal = setup_throwable_lethal
	weapon_origin.linear_velocity = Vector2.ZERO
	
	#sprite dla wybuchu czy machniecia
	$Sprite2D.texture = effect_sprite
	
	if weapon_origin.is_in_group("weapon-white"):
			var direction = get_global_mouse_position() - entity.global_position
			rotation = direction.angle() + 0.5 * PI		
	
	var collision_shape = $"DetectCollision"
	collision_shape.shape.radius = radius
	monitoring = true
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	distribute()

func distribute():
	if not weapon_origin.is_in_group("weapon-throwable-nongranate"): 
		check_bodies()
		if weapon_origin.is_in_group("weapon-throwable"):
			weapon_origin.queue_free()
	
		queue_free()

func check_bodies():
	var real_damage 
	var bodies = get_overlapping_bodies()

	for body in bodies:
		
		var direction_to_body = (body.global_position - global_position).normalized()
		var entity_forward = Vector2.RIGHT.rotated(entity.rotation - deg_to_rad(90))
		
		var angle_diff = direction_to_body.angle_to(entity_forward)
		
		if abs(angle_diff) <= deg_to_rad(angle / 2.0):
			if weapon_origin.is_in_group("weapon-throwable-granate"):
				real_damage = granade_calculate_damage(body)
				if throwable_lethal:
					take_damage(body, real_damage, true)
				else:
					take_damage(body, real_damage)
			
			if weapon_origin.is_in_group("weapon-throwable-nongranate"):
				if throwable_lethal:
					take_damage(body, damage, true)
				else:
					take_damage(body, damage)
			if weapon_origin.is_in_group("weapon-white"):
				real_damage = damage
				take_damage(body, real_damage)

func granade_calculate_damage(body):
	var distance = global_position.distance_to(body.global_position)
	var x = clamp(distance / radius, 0.0 , 1.0)
	#wzor -> f(x) = 1 / (a * (x + 0.5)²) <- napracowalem sie :> ~~Kekls
	var multiplier =  1.0 / (damage * pow(x + 0.5, 2.0))
	var calculated_damage = int(multiplier * 360)
	return calculated_damage

func take_damage(body, real_damage, player_effect: bool = false):
	if player_effect:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(real_damage) 
				print("damage broni: TKP " , real_damage)
		
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(real_damage, stun_timer) 
		  
		elif body.has_method("_take_damage"):
			body._take_damage(real_damage, stun_timer)
