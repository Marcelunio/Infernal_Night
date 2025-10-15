extends Area2D

var direction: Vector2 = Vector2.RIGHT
var bullet_speed: float= 1500
var shooter = null


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	#connect("area_entered", _on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += bullet_speed * direction * delta
	rotation = direction.angle() - deg_to_rad(90)

func _on_body_entered(body):
	print("Pocisk trafił:", body) #body.name
	
	if body == shooter:
		return
	
	if body.is_in_group("enemy"):
		print("Trafiony przeciwnik!")
		
	if body.is_in_group("wall"):
		print("trafiono sciane")
		
	queue_free()
