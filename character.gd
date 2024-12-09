extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer
enum characters {
	Ywi,
	Fauna,
	Bae,
	Mumei,
	IRyS,
	Kronii,
	Sana,
	Lumin,
	Lumin2,
	Nebulamemi,
	length
}
var character_info = [
	["Ywi", 32, 32, 3, false, [[7, 14], [27, 15], [7, 32], [27, 32]]],
	["Fauna", 128, 128, 1, true, [[16, 0], [112, 0], [16, 128], [112, 128]]],
	["Bae", 256, 256, 1, true, [[80, 128], [192, 128], [80, 256], [192, 256]]],
	["Mumei", 256, 256, 1, true, [[80, 128], [170, 128], [80, 256], [170, 256]]],
	["IRyS", 128, 128, 1, true, [[0, 0], [128, 0], [0, 128], [128, 128]]],
	["Kronii", 128, 128, 1, true, [[0, 0], [128, 0], [0, 128], [128, 128]]],
	["Sana", 128, 128, 1, true, [[0, 0], [128, 0], [0, 128], [128, 128]]],
	["Lumin", 30, 30, 3, false, [[0, 0], [128, 0], [0, 128], [128, 128]]],
	["Lumin2", 166, 318, 0.5, true, [[0, 0], [128, 0], [0, 128], [128, 128]]],
	["Ymm", 295, 286, 0.50, true, [[0, 81], [255, 80], [0, 285], [255, 285]]]
]
var selected_character = 0
var pet_state : int = STATE.IDLE

#signals to send when entering and leaving states
signal walking
signal finished_walking
signal change_character

enum STATE{
	IDLE,
	WALK,
	SLEEP,
}

func _ready():
	var pos = character_info[selected_character][5]
	var cscale = character_info[selected_character][3]
	$Polygon2D.polygon[0][0] = pos[0][0] * cscale
	$Polygon2D.polygon[0][1] = pos[0][1] * cscale
	$Polygon2D.polygon[1][0] = pos[1][0] * cscale
	$Polygon2D.polygon[1][1] = pos[1][1] * cscale
	$Polygon2D.polygon[2][0] = pos[3][0] * cscale
	$Polygon2D.polygon[2][1] = pos[3][1] * cscale
	$Polygon2D.polygon[3][0] = pos[2][0] * cscale
	$Polygon2D.polygon[3][1] = pos[2][1] * cscale
	$CPUParticles2D.position.x = (pos[0][0] * cscale) + 16
	$CPUParticles2D.position.y = (pos[0][1] * cscale) + 16
	get_window().mouse_passthrough_polygon = $Polygon2D.polygon
	pet_state = STATE.IDLE
	var spr = get_node("AnimatedSprite2D")
	spr.scale.x = character_info[selected_character][3]
	spr.scale.y = character_info[selected_character][3]
	sprite.play(character_info[selected_character][0] + "_idle")
	if timer.is_stopped():
		timer.start()

func _on_timer_timeout():
	if pet_state == STATE.WALK:
		finished_walking.emit()
	
	await change_state()
	#Timer can change according to state and is random
	match pet_state:
		STATE.IDLE :
			timer.set_wait_time(randi_range(10, 20))
			sprite.play(character_info[selected_character][0] + "_idle")
		#STATE.LOOKAROUND :
			#timer.set_wait_time(randi_range(10, 20))
			#sprite.play("look_around")
		STATE.WALK :
			timer.set_wait_time(randi_range(5, 10))
			sprite.play(character_info[selected_character][0] + "_walk")
		STATE.SLEEP :
			timer.set_wait_time(randi_range(10, 30))
			sprite.play(character_info[selected_character][0] + "_sleep")
	timer.start()

func change_state():
	pet_state = randi_range(0,2)
	if pet_state == STATE.WALK:
		walking.emit()

func ch_character(chara):
	selected_character = chara
	_ready()
	emit_signal("change_character")

func _on_button_pressed():
	#selected_character = randi_range(0, characters.length - 1)
	selected_character += 1
	if selected_character == characters.length:
		selected_character = 0
	ch_character(selected_character)
