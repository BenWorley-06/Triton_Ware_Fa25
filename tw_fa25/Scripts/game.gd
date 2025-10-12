extends Node
@onready var building_manager: BuildingManager = $Managers/BuildingManager
var character_scene = preload("res://Scenes/character.tscn")
# ---- end day variables
@onready var end_day_layer: CanvasLayer = $end_day
@onready var end_day_label: Label = $end_day/TextureRect/MarginContainer/VBoxContainer/Day
@onready var faith_label: Label = $end_day/TextureRect/MarginContainer/VBoxContainer/Faith

var day = 0;

func add_character():
	var character=character_scene.instantiate()
	character.global_position=Vector2(200, 200)
	add_child(character)
	
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("ui_accept"):
		add_character()
var paused = false

func end_day():
	
	if paused:
		for node in get_tree().get_nodes_in_group("pausable"):
			node.set_physics_process(true)
			node.set_process(true)
		paused = false
		end_day_layer.visible = false;
	else:
		day += 1
		for node in get_tree().get_nodes_in_group("pausable"):
			node.set_physics_process(false)
			node.set_process(false)
<<<<<<< Updated upstream
=======
		end_day_layer.visible = true
		update_labels()
>>>>>>> Stashed changes
		paused = true
		
		end_day_layer.visible = true;
		end_day_label.text = "day: %d" % day
	print("debug")
	

<<<<<<< Updated upstream
func _input(event):
=======
	print("Day state toggled. Paused:", paused)

func update_labels():
	end_day_label.text = "Day: %d" % day
	faith_label.text = "Faith: %d" % stats.faith

# ---- Input ----
func _input(event: InputEvent) -> void:
>>>>>>> Stashed changes
	if event.is_action_pressed("debug"):
		end_day()
		
		
	if event.is_action_pressed("escape"): # "quit" is the action defined in Input Map
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
