extends Node
@onready var building_manager: BuildingManager = $Managers/BuildingManager
<<<<<<< Updated upstream
=======
@onready var population_manager: PopulationManager = $Managers/PopulationManager
@onready var resource_manager: ResourceManager = $Managers/ResourceManager
>>>>>>> Stashed changes
var character_scene = preload("res://Scenes/character.tscn")
# ---- end day variables
@onready var end_day_layer: CanvasLayer = $end_day
@onready var end_day_label: Label = $end_day/TextureRect/MarginContainer/VBoxContainer/Day
@onready var faith_label: Label = $end_day/TextureRect/MarginContainer/VBoxContainer/Faith

var day = 0;

<<<<<<< Updated upstream
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
=======
# ---- Time Management ----
var day_timer: float = 0.0
var day: int = 0
var paused: bool = false
var end_day_cooldown: bool = false

# ---- ui
@onready var ui: MarginContainer = $ui
@onready var faith_progress_bar: ProgressBar = $ui/VBoxContainer/faith

# ---- Process ----
func _process(delta: float) -> void:
	
	if paused:
		return  # Stop day progression during end screen
	update_ui()
	day_timer += delta
	if day_timer >= stats.time_in_day:
		end_day()

	# Smooth color transition
	var t = fmod(day_timer / stats.time_in_day, 1.0)
	var c1: Color
	var c2: Color
	var local_t: float

	if t < 0.25:
		c1 = morning_color
		c2 = afternoon_color
		local_t = t / 0.25
	elif t < 0.5:
		c1 = afternoon_color
		c2 = evening_color
		local_t = (t - 0.25) / 0.25
	elif t < 0.75:
		c1 = evening_color
		c2 = night_color
		local_t = (t - 0.5) / 0.25
	else:
		c1 = night_color
		c2 = morning_color
		local_t = (t - 0.75) / 0.25

	overlay.color = c1.lerp(c2, local_t)


# ---- End Day ----
func end_day() -> void:
	if end_day_cooldown:
		return  # prevents spam
	end_day_cooldown = true
	await get_tree().create_timer(0.2).timeout
	end_day_cooldown = false

	if paused:
		# Resume game
>>>>>>> Stashed changes
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



# --- ui
func update_ui():
	update_faith()
	return

func update_faith():
	faith_progress_bar.value = resource_manager.faith
	return
