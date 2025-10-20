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
	rotation = direction.angle() - PI/2

func _on_body_entered(body):
	if body == shooter:
		return
	
	print("Pocisk trafił: ", body)
	
	if body.is_in_group("enemy"):
		print("Trafiony przeciwnik!")
	
	if body.name == "Layout":
		print("Trafiono element layout'u!")
	queue_free()
