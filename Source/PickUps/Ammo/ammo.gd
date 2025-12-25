#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Area2D

@export var ammo_type: String = ""
@export var ammo_count: int
var max_ammo_count: int

func _ready() -> void:#connect body_entered|exited
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	max_ammo_count = ammo_count

func _on_body_entered(body) -> void:#check
	if body.name == "Player":
		body.inventory.is_ammo_full(self)

func _on_body_exited(body) -> void:#uncheck
	if body.name == "Player":
		body.inventory.ammo_exit(self)

func ammo_pick_up(body) -> void:#ammo pick_up
	var inv = body.inventory
	var needed = inv.ammo_container[ammo_type]["max"] - inv.ammo_container[ammo_type]["current"]
	
	if ammo_count - needed <= 0:
		inv.ammo_container[ammo_type]["current"] += ammo_count
		die()
		return
	else:
		inv.ammo_container[ammo_type]["current"] += needed
		ammo_count -= needed
		
	sprite_change()

func sprite_change() -> void:#change of sprite:
	var ammo_percentage = float(ammo_count) / max_ammo_count
		
	if ammo_percentage < 0.2:
		pass #zmiana na sprite gdzie troche znknelo naboi
	elif ammo_percentage < 0.5:
		pass #zmina na sprite gdzienie ma praiwe wogole nabojow

func die():#delete
	print("DEBUG ammo.gd | Ammo sie skonczylo w ", self.name)
	queue_free()
	
