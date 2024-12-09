extends Node2D

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
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

signal change_character



func _on_bae_pressed():
	change_character.emit(2)
	$Window.visible = false


func _on_button_pressed():
	get_tree().quit()


func _on_fauna_pressed():
	change_character.emit(1)
	$Window.visible = false


func _on_i_ry_s_pressed():
	change_character.emit(characters.IRyS)
	$Window.visible = false


func _on_mumei_pressed():
	change_character.emit(characters.Mumei)
	$Window.visible = false


func _on_kronii_pressed():
	change_character.emit(characters.Kronii)
	$Window.visible = false


func _on_sana_pressed():
	change_character.emit(characters.Sana)
	$Window.visible = false


func _on_ywi_pressed():
	change_character.emit(characters.Ywi)
	$Window.visible = false


func _on_Lumin_pressed() -> void:
	change_character.emit(characters.Lumin)
	$Window.visible = false


func lumin2() -> void:
	change_character.emit(characters.Lumin2)
	$Window.visible = false


func _on_nebulamemi_pressed() -> void:
	change_character.emit(characters.Nebulamemi)
	$Window.visible = false
