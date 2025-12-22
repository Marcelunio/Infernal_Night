extends Area2D

var direction: Vector2 = Vector2.RIGHT
var bullet_speed: float
var shooter = null
var weapon_origin = null
var damage: int 


func _ready():
	add_to_group("projectiles")
	connect("body_entered", _on_body_entered)
	bullet_speed= weapon_origin.bullet_speed
	if weapon_origin:
		damage = weapon_origin.weapon_damage
	else:
		print("DEBUG - weapon_origin jest null!")
		
	$BulletAnimatedSprite.animation = "BANG"
	$BulletAnimatedSprite.play()

func _physics_process(delta):
	position += direction * bullet_speed * delta
	rotation = direction.angle() - PI / 2

func _on_body_entered(body: Node) -> void:
	if body == shooter:#sam caly czas sie w tym gubie... Shooter jest przypisywany w najniszej hierarchi klas weapon, jest on poto zeby zdefioniowac jakiedy strzela np. czy gracz czy przeciwnik ~~Kekls
		return

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, 0.12) 
			print("damage broni: TK " , damage)
			  
		elif body.has_method("_take_damage"):
			body._take_damage(damage, 0.12)
			print("damage broni: _TK " , damage)
			
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("gracz dostał:", damage, "-hp")
			
	$BulletAnimatedSprite.stop()
	queue_free()
