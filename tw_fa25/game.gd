extends Node
@onready var building_manager: BuildingManager = $Managers/BuildingManager
var character_scene = preload("res://Scenes/character.tscn")

func _ready() -> void:
	building_manager.place_scaffold(Vector2(200,200))

func add_character():
	var character=character_scene.instantiate()
	character.global_position=Vector2(200, 200)
	add_child(character)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		add_character()
