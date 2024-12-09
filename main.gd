extends Node2D

@onready var _MainWindow: Window = get_window()
@onready var char_info: Array = $Character.character_info
@onready var selected_character: int = $Character.selected_character
@onready var char_sprite: AnimatedSprite2D = $Character/AnimatedSprite2D
@onready var emitter: CPUParticles2D = $Character/CPUParticles2D

var player_size: Vector2i = Vector2i(32*3,32*3)
var gravity: int = 10
#The offset between the mouse and the character
var mouse_offset: Vector2 = Vector2.ZERO
var selected: bool = false
#This will be the position of the pet above the taskbar
var original_taskbar_offset: int = 0
var taskbar_offset: int = 0
var taskbar_pos: int = (DisplayServer.screen_get_usable_rect().size.y - player_size.y) - taskbar_offset
var screen_width: int = DisplayServer.screen_get_usable_rect().size.x
var first_width: int = DisplayServer.screen_get_usable_rect().size.x
var dualscreen: bool = false;
#If true the character will move
var is_walking: bool = false
var walk_direction: int = 1
#Character walk speed
const WALK_SPEED = 150

func _ready():
	if dualscreen:
		screen_width = DisplayServer.screen_get_usable_rect().size.x * 2
	get_window().mouse_passthrough_polygon = $Character/Polygon2D.polygon
	#Change the size of the window
	_MainWindow.min_size = player_size
	_MainWindow.size = _MainWindow.min_size
	#Places the character in the middle of the screen and on top of the taskbar
	@warning_ignore("integer_division")
	_MainWindow.position = Vector2i(DisplayServer.screen_get_size().x/2 - (player_size.x/2), DisplayServer.screen_get_size().y/2)

func _process(delta):
	if _MainWindow.position.x > first_width + (player_size.y / 2):
		taskbar_offset = 0
	else:
		taskbar_offset = original_taskbar_offset
	taskbar_pos = (DisplayServer.screen_get_usable_rect().size.y - player_size.y) - taskbar_offset
	if _MainWindow.position.y < taskbar_pos and selected == false:
		_MainWindow.position.y += gravity
	if _MainWindow.position.y > taskbar_pos:
		_MainWindow.position.y = taskbar_pos
	if selected:
		follow_mouse()
	if is_walking:
		walk(delta)
	move_pet()
	#emit heart particles when petted
	if Input.is_action_just_pressed("pet"):
		emitter.emitting = true

func follow_mouse():
	#Follows mouse cursor but clamps it on the taskbar
	@warning_ignore("narrowing_conversion")
	_MainWindow.position = Vector2i(get_global_mouse_position().x
		 + mouse_offset.x, 
		get_global_mouse_position().y
		 + mouse_offset.y) 

func move_pet():
	#On right click and hold it will follow the pet and when released
	#it will stop following
	if Input.is_action_pressed("move"):
		selected = true
		mouse_offset = _MainWindow.position - Vector2i(get_global_mouse_position()) 
	if Input.is_action_just_released("move"):
		$Config/Window.visible = !$Config/Window.visible
		selected = false

func clamp_on_screen_width(pos, player_width):
	return clampi(pos, 0, screen_width - player_width)

func walk(delta):
	#Moves the pet
	_MainWindow.position.x = _MainWindow.position.x + WALK_SPEED * delta * walk_direction
	#Clamps the pet position on the width of screen
	_MainWindow.position.x = clampi(_MainWindow.position.x, 0
			,clamp_on_screen_width(_MainWindow.position.x, player_size.x))
	#Changes direction if it hits the sides of the screen
	if ((_MainWindow.position.x == (screen_width - player_size.x)) or (_MainWindow.position.x == 0)):
		walk_direction = walk_direction * -1
		char_sprite.flip_h = !char_sprite.flip_h

func choose_direction():
	if (randi_range(1,2) == 1):
		walk_direction = 1
		char_sprite.flip_h = char_info[selected_character][4]
	else:
		walk_direction = -1
		char_sprite.flip_h = !char_info[selected_character][4]

func _on_character_walking():
	is_walking = true
	choose_direction()

func _on_character_finished_walking():
	is_walking = false


func _on_character_change_character():
	var character = get_node("Character")
	var info = character.character_info[character.selected_character]
	player_size = Vector2i(info[1]*info[3],info[2]*info[3])
	char_sprite.flip_h = info[4]
	taskbar_pos = (DisplayServer.screen_get_usable_rect().size.y - player_size.y) - taskbar_offset
	_ready()


func _on_config_change_character(chara):
	var character = get_node("Character")
	var info = character.character_info[chara]
	character.ch_character(chara)
	is_walking = false
	player_size = Vector2i(info[1]*info[3],info[2]*info[3])
	char_sprite.flip_h = info[4]
	taskbar_pos = (DisplayServer.screen_get_usable_rect().size.y - player_size.y) - taskbar_offset
	_ready()
