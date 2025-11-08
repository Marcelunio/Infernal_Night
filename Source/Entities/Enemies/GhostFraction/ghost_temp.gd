extends Enemy

var noVisibleSprite 
var visibleSprite

func __ready():
	noVisibleSprite = preload("res://Assets/Entities/Enemies/GhostFraction/GhostTEMP/GhostNonVisibleTEMP.png")
	visibleSprite = preload("res://Assets/Entities/Enemies/GhostFraction/GhostTEMP/GhostVisibleTEMP.png")

func __find_target():
	if target_path and has_node(target_path):
		return get_node(target_path)
	else:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			return players[0]

func __die():
	queue_free()
	
func __on_physics_process(delta: float) -> void:
	var dist = global_position.distance_to(target.global_position)
	
	if dist <= 576:
		$EnemySprite.texture = noVisibleSprite
		$EnemyCollision.disabled = true
		$Hurtbox/HurtDetect.disabled = true
		$NavigationAgent.navigation_layers = 2
		speed = 150
		
		collision_layer = 0
		collision_mask = 0
		
		phasing = true
	else:
		$EnemySprite.texture = visibleSprite
		$EnemyCollision.disabled = false
		$Hurtbox/HurtDetect.disabled = false
		$NavigationAgent.navigation_layers = 1
		speed = 300
		
		phasing = false
