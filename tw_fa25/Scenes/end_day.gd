extends CanvasLayer
@onready var button: Button = $TextureRect/MarginContainer/VBoxContainer/Button
@onready var game = get_node("/root/Game")

func _on_button_pressed() -> void:
	print('pressed')
	game.end_day()
