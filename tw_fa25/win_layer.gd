extends CanvasLayer
@onready var game = get_node("/root/Game")
@onready var win_text: Label = $Control/VBoxContainer/win_text
@onready var return_button: Button = $Control/VBoxContainer/return
@onready var endless: Button = $Control/VBoxContainer/endless

var active=false

func _ready() -> void:
	visible=false

func activate():
	active=true
	visible=true

func _on_return_pressed() -> void:
	if active:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_endless_pressed() -> void:
	if active:
		active=false
		visible=false
