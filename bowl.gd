extends Node2D
@onready var bowl = $Window
var taskbar_pos = 1920
var gravity = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	bowl.position.y = clamp(bowl.position.y + gravity, 0, taskbar_pos + 256 / 2)
	pass
