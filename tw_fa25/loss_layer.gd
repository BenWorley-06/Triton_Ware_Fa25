extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _input(event):
	if event.is_action_pressed("escape"): # "quit" is the action defined in Input Map
		get_tree().quit()
		

func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	pass # Replace with function body.


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui/main.tscn")
	pass # Replace with function body.
