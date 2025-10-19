extends Node2D

@export var stats: GameStats
@export var overlay: ColorRect

@onready var building_manager: BuildingManager = $Managers/BuildingManager
@onready var population_manager: PopulationManager = $Managers/PopulationManager
@onready var resource_manager: ResourceManager = $Managers/ResourceManager
@onready var gui = get_node("/root/Game/GUI")
var character_scene = preload("res://Scenes/character/character.tscn")

# ---- End day variables ----
@onready var end_day_layer: CanvasLayer = $end_day
@onready var end_day_label: Label = $end_day/TextureRect/MarginContainer/VBoxContainer/Day
@onready var faith_label: Label = $end_day/TextureRect/MarginContainer/VBoxContainer/Faith

@onready var win_layer: CanvasLayer = $win_layer

# ---- loss
@onready var loss_layer: CanvasLayer = $loss_layer

# ---- Day/Night Tint Colors ----
var morning_color: Color = Color(0.2, 0.3, 0.5, 0.5)
var afternoon_color: Color = Color(1.0, 0.6, 0.2, 0.3)
var evening_color: Color = Color(0.1, 0.05, 0.2, 0.6)
var night_color: Color = Color(0, 0, 0.1, 0.7)

# ---- Time Management ----
var day_timer: float = 0.0
var day: int = 0
var paused: bool = false
var end_day_cooldown: bool = false
@export var faith_win: int = 200
var has_won=false

func _ready():
	print(resource_manager.bread)

# ---- Process ----
func _process(delta: float) -> void:
	if paused:
		return  # Stop day progression during end screen
	day_timer += delta
	if day_timer >= stats.time_in_day:
		end_day()
	manage_day_tint()
	faith_conditions()
	

func faith_conditions():
	if resource_manager.faith == 0.0:
		faith_loss()
	return

func faith_loss():
	# End day
	for node in get_tree().get_nodes_in_group("pausable"):
		node.set_physics_process(false)
		node.set_process(false)
	loss_layer.visible = true
	paused = true
	return

func win():
	has_won=true
	win_layer.activate()

func manage_day_tint():
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
	gui.seconds = day_timer
	if end_day_cooldown:
		return  # prevents spam
	end_day_cooldown = true
	await get_tree().create_timer(0.2).timeout
	end_day_cooldown = false

	if paused:
		# Resume game
		for node in get_tree().get_nodes_in_group("pausable"):
			node.set_physics_process(true)
			node.set_process(true)
		paused = false
		end_day_layer.start_day()
	else:
		# End day
		day += 1
		day_timer = 0  # reset timer
		var data: Array=population_manager.new_day()
		var bread_loss: int = data[0]
		var faith_gain: int = data[1]
		for node in get_tree().get_nodes_in_group("pausable"):
			node.set_physics_process(false)
			node.set_process(false)
		end_day_layer.end_day(bread_loss,faith_gain)
		paused = true
		if day>=7 and not has_won:
			if stats.faith>=faith_win:
				win()
			else:
				faith_loss()

	print("Day state toggled. Paused:", paused)

# ---- Input ----
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		end_day()
	elif event.is_action_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
	elif event.is_action_pressed("auto_win"):
		win()
