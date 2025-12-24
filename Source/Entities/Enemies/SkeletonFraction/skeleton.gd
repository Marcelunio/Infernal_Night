#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Enemy

var post_mortem_damage: float
var timer_started: bool = false

func __ready():
	post_mortem = true
	post_mortem_max_hp = 50
	$PostMortemTimer.timeout.connect(__revival)

func __find_target():
	if target_path and has_node(target_path):
		return get_node(target_path)
	else:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			return players[0]
			
func __on_damage_taken(amount) -> void:
	if post_mortem_down:
		print("POST MORTEM DAMAGE")
		post_mortem_damage = amount	

func __post_mortem() -> void:
	print("POST MORTEM START")
	post_mortem_down = true
	$AnimatedSprite2D.animation = "down"
	$AnimatedSprite2D.play()
	if !timer_started:
		print("TIMER START")
		timer_started = true
		$PostMortemTimer.start()
		
	
	post_mortem_max_hp -= post_mortem_damage
	if post_mortem_max_hp <= 0:
		__die()
		return
	
func __die() -> void:
	queue_free()	
	
func __revival() -> void:
	$AnimatedSprite2D.stop()
	post_mortem_max_hp = 50
	hp =max_hp
	post_mortem_down = false
	timer_started = false
	
func __on_physics_process(_delta: float) -> void:
	if post_mortem_down:
		return 
		
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.animation = "walking"
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
