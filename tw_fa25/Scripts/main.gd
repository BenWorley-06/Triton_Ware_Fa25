extends Node2D
@onready var splash: Label = $splash
@onready var background: TextureRect = $background
@onready var title: Sprite2D = $Title2
@onready var white_flash: TextureRect = $white_flash

@export var splash_data: SplashData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	splash.text = splash_data.texts.pick_random()
	splash.scale = Vector2.ONE
	animate_splash()
	animate_background()
	animate_title()

func animate_splash() -> void:
	var tween = create_tween()
	tween.set_loops() 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(splash, "scale", Vector2.ONE * 1.1, 1.0)
	tween.tween_property(splash, "scale", Vector2.ONE * 0.9, 1.0)
	
func animate_background() -> void:

	# Bobbing motion
	var pos_tween = create_tween()
	pos_tween.set_loops()
	pos_tween.set_trans(Tween.TRANS_SINE)
	pos_tween.set_ease(Tween.EASE_IN_OUT)
	
	var original_y = background.position.y
	pos_tween.tween_property(background, "position:y", original_y + 20, 10.0)
	pos_tween.tween_property(background, "position:y", original_y - 20, 10.0)

func animate_title() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var original_y = title.position.y
	tween.tween_property(title, "position:y", original_y + 10, 2.5)
	tween.tween_property(title, "position:y", original_y - 10, 2.5)
func _process(delta: float) -> void:
	pass

func flash_and_change_scene(next_scene: String) -> void:
	var tween = create_tween()
	# Make sure white_flash is visible
	white_flash.visible = true
	white_flash.modulate.a = 0.0
	
	# Fade to white quickly
	tween.tween_property(white_flash, "modulate:a", 1.0, 0.3)
	# Wait a short moment at full white, then change scene
	tween.tween_callback(func ():
		get_tree().change_scene_to_file(next_scene)
	)

func _on_start_pressed() -> void:
	flash_and_change_scene("res://Scenes/game.tscn")
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("escape"): # "quit" is the action defined in Input Map
		get_tree().quit()
			
func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
