extends CanvasLayer
@onready var game = get_node("/root/Game")
@onready var win_text: Label = $Control/VBoxContainer/win_text
@onready var return_button: Button = $Control/VBoxContainer/return
@onready var endless: Button = $Control/VBoxContainer/endless
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

var active=false

func _ready() -> void:
	visible=false

func activate():
	active=true
	visible=true
	start_bob()

func _on_return_pressed() -> void:
	if active:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_endless_pressed() -> void:
	if active:
		active=false
		visible=false
		
func start_bob():
	var start_y = sprite_2d_2.position.y
	var bob_tween = create_tween()
	bob_tween.set_loops() # infinite loop
	bob_tween.tween_property(sprite_2d_2, "position:y", start_y - 6, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(sprite_2d_2, "position:y", start_y + 6, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
