extends Area2D

func _ready() -> void:
	pass  

func setup(melee_range, melee_angle, player) -> void:
	print("dziala co nie?")
	var collision_shape = $"DetectCollision"
	collision_shape.shape.radius = melee_range
	monitoring = true
	
	await get_tree().physics_frame
	
	var bodies = get_overlapping_bodies()
	print("Znaleziono bodies: ", bodies.size()) 
	
	for body in bodies:
		
		var direction_to_body = (body.global_position - global_position).normalized()
		var player_forward = Vector2.RIGHT.rotated(player.rotation - deg_to_rad(90))
		
		var angle_diff = direction_to_body.angle_to(player_forward)
		
		if abs(angle_diff) <= deg_to_rad(melee_angle / 2.0):
			if body.is_in_group("enemy"):
				print("Trafiony!")
		else:
			print("Poza kątem ataku")
	
	queue_free()
