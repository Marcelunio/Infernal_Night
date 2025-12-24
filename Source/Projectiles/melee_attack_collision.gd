#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Area2D
var weapon_origin = null
var stun_timer :float
var damage: int

func _ready() -> void:
	if weapon_origin:
		damage = weapon_origin.weapon_damage
		if damage == 0:
			stun_timer = 5
		else:
			stun_timer = 1.2	
	else:
		print("DEBUG - weapon_origin jest null!")

func setup(melee_range, melee_angle, entity, effect_sprite, throwable_lethal:bool = false) -> void:
	#sprite dla wybuchu czy machniecia
	$Sprite2D.texture = effect_sprite
	var direction = get_global_mouse_position() - entity.global_position
	rotation = direction.angle() + 0.5 * PI
	
	var real_damage 
	var collision_shape = $"DetectCollision"
	collision_shape.shape.radius = melee_range
	monitoring = true
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var bodies = get_overlapping_bodies()
	print("Znaleziono bodies: ", bodies.size()) 
	
	for body in bodies:
		print(weapon_origin)
		
		var direction_to_body = (body.global_position - global_position).normalized()
		var entity_forward = Vector2.RIGHT.rotated(entity.rotation - deg_to_rad(90))
		
		var angle_diff = direction_to_body.angle_to(entity_forward)
		
		if abs(angle_diff) <= deg_to_rad(melee_angle / 2.0):
			if weapon_origin.is_in_group("weapon-throwable-granate"):
				real_damage = granade_calculate_damage(body, melee_range)
				if throwable_lethal:
					take_damage(body, real_damage, true)
				else:
					take_damage(body, real_damage)
					
			if weapon_origin.is_in_group("weapon-throwable-nongranate"):
				if throwable_lethal:
					pass
				else:
					pass
			if weapon_origin.is_in_group("weapon-white"):
				real_damage = damage
				take_damage(body, real_damage)
		else:
			print("Poza kątem ataku")
	
	if weapon_origin.is_in_group("weapon-throwable"):		
		weapon_origin.queue_free()
		
	queue_free()
	
func take_damage(body, real_damage, player_effect: bool = false):
	if player_effect:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(real_damage) 
				print("damage broni: TKP " , real_damage)
		
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(real_damage, stun_timer) 
			print("damage broni: TK " , real_damage)
		  
		elif body.has_method("_take_damage"):
			body._take_damage(real_damage, stun_timer)
			print("damage broni: _TK " , real_damage)
		
func granade_calculate_damage(body, melee_range):
	var distance = global_position.distance_to(body.global_position)
	var x = clamp(distance / melee_range, 0.0 , 1.0)
	#wzor -> f(x) = 1 / (a * (x + 0.5)²) <- napracowalem sie :> ~~Kekls
	var multiplier =  1.0 / (damage * pow(x + 0.5, 2.0))
	var calculated_damage = int(multiplier * 360)
	return calculated_damage
	
