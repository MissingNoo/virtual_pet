extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer
enum characters {
	Ywi,
	MikuD,
	Bae,
	Mumei,
	IRyS,
	Kronii,
	Sana,
	Lumin,
	March,
	Teio,
	Dog,
	length
}
var new_character_info = {
	"Bae": {
		"climb_offset" : {
			"left" : 120,
			"right" : 135
		},
		"states" : 
			[
				STATE.IDLE,
				STATE.WALK,
				STATE.SLEEP,
				STATE.CLIMB,
				STATE.IDOL,
				STATE.SIT
			],
		"state_count" : 5
	},
	"March" : {
		
	}
}

var character_info = [
	["Ywi", 32, 32, 3, false, [[7, 14], [27, 15], [7, 32], [27, 32]], false],
	["MikuD", 720, 662, 0.28, false, [[200, 180], [460, 180], [200, 581], [460, 460]], false],
	["Bae", 256, 256, 1, true, [[80, 128], [192, 128], [80, 256], [192, 256]], true],
	["Mumei", 256, 256, 1, true, [[80, 128], [170, 128], [80, 256], [170, 256]], false],
	["IRyS", 128, 128, 1, true, [[0, 0], [128, 0], [0, 128], [128, 128]], false],
	["Kronii", 128, 128, 1, true, [[0, 0], [128, 0], [0, 128], [128, 128]], false],
	["Sana", 128, 128, 1, true, [[0, 0], [128, 0], [0, 128], [128, 128]], false],
	["Lumin", 30, 30, 3, false, [[0, 0], [128, 0], [0, 128], [128, 128]], false],
	["March", 512, 441, 0.5, true, [[0, 0], [512, 0], [0, 441], [512, 441]], false],
	#["Ymm", 295, 286, 0.3, false, [[0, 81], [255, 80], [0, 285], [255, 285]], false]
	["Teio", 460, 581, 0.5, false, [[200, 180], [460, 180], [200, 581], [460, 460]], false],
	["Dog", 716, 1067, 0.3, false, [[98, 350], [475, 350], [98, 1066], [475, 1066]], false],
]
var selected_character = 0
var pet_state : int = STATE.IDLE
var climb_side = 0
var last_climb_side = 0
var climb_height = 00
var last_state = 0
#signals to send when entering and leaving states
signal walking
signal finished_walking
signal climbing
signal finished_climbing
signal change_character

enum STATE{
	IDLE,
	WALK,
	SLEEP,
	CLIMB,
	IDOL,
	SIT,
	FALL,
	FELL
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
	if pet_state == STATE.CLIMB:
		finished_climbing.emit()
	
	await change_state()
	#Timer can change according to state and is random
	match pet_state:
		STATE.IDLE :
			timer.set_wait_time(randi_range(10, 20))
			sprite.play(character_info[selected_character][0] + "_idle")
		#STATE.LOOKAROUND :
			#timer.set_wait_time(randi_range(10, 20))
			#sprite.play("look_around")
		STATE.FALL:
			sprite.play(character_info[selected_character][0] + "_fall")
		STATE.WALK :
			timer.set_wait_time(randi_range(5, 10))
			get_parent().WALK_SPEED = randi_range(150, 300)
			if get_parent().WALK_SPEED <= 300:
				sprite.play(character_info[selected_character][0] + "_sprint")
			if get_parent().WALK_SPEED <= 250:
				sprite.play(character_info[selected_character][0] + "_run")
			if get_parent().WALK_SPEED <= 200:
				sprite.play(character_info[selected_character][0] + "_walk")
		STATE.SLEEP :
			timer.set_wait_time(randi_range(10, 30))
			sprite.play(character_info[selected_character][0] + "_sleep")
		STATE.SIT :
			timer.set_wait_time(randi_range(5, 10))
			sprite.play(character_info[selected_character][0] + "_sit")
		STATE.CLIMB :
			last_climb_side = climb_side
			timer.set_wait_time(randi_range(5, 20))
			if get_parent()._MainWindow.position.y == get_parent().taskbar_pos:
				sprite.play(character_info[selected_character][0] + "_walk")
			climbing.emit()
		STATE.IDOL :
			sprite.play("Bae_idol")
			timer.set_wait_time(randi_range(8, 15))
	if pet_state != STATE.FALL or pet_state != STATE.FELL:
		timer.start()

func change_state():
	var rng = randi_range(0, 5)
	if pet_state == STATE.CLIMB:
		var mx = get_parent()._MainWindow.position.x
		if get_parent()._MainWindow.position.y > climb_height:
			return
		if climb_side == -1 and mx == 0 - new_character_info.Bae.climb_offset.left:
			pet_state = rng
		if climb_side == 1 and mx == get_parent().screen_width - new_character_info.Bae.climb_offset.right:
			pet_state = rng
	else :
		pet_state = rng
	if pet_state == STATE.CLIMB:
		climb_side = randi_range(-1,1)
		climb_height = randi_range(10, get_parent().taskbar_pos - 80)
		if last_climb_side != climb_side:
			pet_state = STATE.FALL
			last_state = STATE.FALL
			finished_climbing.emit()
			last_climb_side = climb_side
		if climb_side == 0:
			climb_side = 1
		if pet_state != STATE.FALL:
			climbing.emit()
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
