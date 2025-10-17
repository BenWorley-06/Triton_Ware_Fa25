extends Node2D
@onready var splash: Label = $splash
@export var splash_data: SplashData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	splash.text = splash_data.texts.pick_random()
	splash.scale = Vector2.ONE
	animate_splash()

func animate_splash() -> void:
	var tween = create_tween()
	tween.set_loops() 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(splash, "scale", Vector2.ONE * 1.1, 1.0)
	tween.tween_property(splash, "scale", Vector2.ONE * 0.9, 1.0)

func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("escape"): # "quit" is the action defined in Input Map
		get_tree().quit()
			
func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
