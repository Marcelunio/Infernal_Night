#Zrobił to Kekls, wszelkie niepewności oraz pytania kierować do mnie...
#Znane bugi: 0
extends Control

var from_main_menu: bool = false

const DIFFICULTIES: Dictionary = {
	"easy": 1,
	"medium": 2,
	"hard": 3
}

const ROOM_TABLE: Dictionary = {
	0: [5, 8, 12],
	1: [5, 8, 12],
	2: [8, 10, 14],
	3: [8, 10, 14],
	4: [10, 12, 16],
	5: [10, 12, 16],
	6: [12, 14, 18],
	7: [12, 14, 18],
}

const TIMES_PER_ROOM: Array = [120, 90, 45] 

const BONUS_MULTIPLIER: Array =[1, 1.5, 2]

func _ready() -> void:
	await get_tree().physics_frame
	
	if not from_main_menu:
		PlayerData.floor_stage = "Choice"
		var audio_node = AudioStreamPlayer.new()
		audio_node.stream = load("res://Sounds/Music/Main_menu.ogg")
		audio_node.autoplay = true
		audio_node.bus = "Music"
		add_child(audio_node)
		audio_node.play()
		seed_generate()
	else:
		get_parent().seed_generate.connect(seed_generate)
		visible = false
		
	
	for difficulty in DIFFICULTIES:
		var label = Label.new()
		var button = Button.new()
		var v_box = VBoxContainer.new()
		
		var rooms = calculate_rooms(DIFFICULTIES[difficulty])
		var time = calculate_time(DIFFICULTIES[difficulty], rooms)
		
		var s = time % 60
		var m = int(time/60)
		var time_text = "%d:%d" % [m,s]
		
		var bonus = ceili((6 * BONUS_MULTIPLIER[DIFFICULTIES[difficulty] -1]) * 1.5)
		
		label.text = str(difficulty) + ":\nRooms: " + str(rooms) + "\nMax time for bonus: " + str(time_text) + "\nMax  coin bonus: " + str(bonus)
		button.text = "play"

		button.pressed.connect(_pressed.bind(difficulty))
		button.add_to_group("Buttons")

		v_box.add_child(label)
		v_box.add_child(button)
		$HBoxContainer.add_child(v_box)
	
func start() -> void:
	visible = true
	for Vbox in $HBoxContainer.get_children():
		for control in Vbox.get_children():
			control.add_theme_font_size_override("font_size",DisplayServer.window_get_size().y/36)
	
func _pressed(difficulty) -> void:
	PlayerData.max_rooms = calculate_rooms(DIFFICULTIES[difficulty])
	PlayerData.floor_max_time = calculate_time(DIFFICULTIES[difficulty], PlayerData.max_rooms)
	PlayerData.bonus = ceili(6 * BONUS_MULTIPLIER[DIFFICULTIES[difficulty] -1])
	PlayerData.level += 1
	PlayerData.floor_time = 0
	GameState._CHANGE_ROOT("res://Scenes/Floors/Main/Main.tscn")

func calculate_rooms(difficulty: int) -> int:
	var level = min(PlayerData.level, 7)
	var base = ROOM_TABLE[level][difficulty - 1]
	var rand = randi_range(-3, 3)
	return max(5, base + rand)

func calculate_time(difficulty: int, rooms: int) -> int:
	var base = TIMES_PER_ROOM[difficulty - 1]
	var flat_time = base * rooms
	var max_loss = int((base / 3) * rooms)
	var rand = randi_range(-max_loss, 0)
	return flat_time + rand

func seed_generate() -> void:
	if PlayerData.dungeon_seed == 0:
		PlayerData.dungeon_seed = randi()
	
	seed(PlayerData.dungeon_seed + PlayerData.level)
