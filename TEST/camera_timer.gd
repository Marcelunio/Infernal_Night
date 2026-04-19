extends HBoxContainer

@onready var rec_dot = $RecDot
@onready var time_label = $TimeLabel

var blink_timer: float = 0.0



func _process(delta: float) -> void:
	# migająca kropka
	blink_timer += delta
	if blink_timer > 0.5:
		blink_timer = 0.0
		if rec_dot.modulate.a == 1.0:
			rec_dot.modulate.a = 0.0
		else:
			rec_dot.modulate.a = 1.0
	
	# czas
	var t = PlayerData.floor_time
	var hours = int(t / 3600)
	var minutes = int(fmod(t, 3600) / 60)
	var seconds = int(fmod(t, 60))
	var millis = int(fmod(t, 1.0) * 100)
	time_label.text = "%02d:%02d:%02d:%02d" % [hours, minutes, seconds, millis]
