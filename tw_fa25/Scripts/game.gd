extends Node
@onready var building_manager: BuildingManager = $Managers/BuildingManager
var character_scene = preload("res://Scenes/character.tscn")

func add_character():
	var character=character_scene.instantiate()
	character.global_position=Vector2(200, 200)
	add_child(character)
	
func _process(delta: float) -> void:
<<<<<<< Updated upstream
	if Input.is_action_just_pressed("ui_accept"):
		add_character()
=======
	day_timer+=delta
	if day_timer>=stats.time_in_day:
		end_day()

func end_day():
	day+=1
	day_timer=0

func _input(event):
	if event.is_action_pressed("escape"): # "quit" is the action defined in Input Map
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
>>>>>>> Stashed changes
