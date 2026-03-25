extends EnemyProjectile
class_name GhostProjectile

func _ready() -> void:
	speed = 450.0
	damage = 8
	super._ready()
