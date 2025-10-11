extends Node
@onready var game: Node = $".."

var character_scene = preload("res://Scenes/character.tscn")

func add_character():
	var character=character_scene.instantiate()
	character.global_position=Vector2(200, 200)
	game.add_child(character)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		add_character()
