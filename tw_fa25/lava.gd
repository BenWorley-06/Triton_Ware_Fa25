extends Area2D
class_name LavaSource

@onready var game = get_node("/root/Game")
@export var spread_time_og: float = 8
@export var fire_scene: PackedScene
@onready var space = get_world_2d().direct_space_state
var timer: float = 0
var spread_time: float

func _ready() -> void:
	spread_time= spread_time_og

func _process(delta: float) -> void:
	timer+=delta
	if timer>=spread_time:
		spread_time=spread_time_og*randf_range(0.8,5)
		if game.boost_fires or game.day==6:
			spread_time=spread_time/5
		timer=0
		spawn_fire_nearby()

func spawn_fire_nearby() -> void:
	# pick a random offset near lava
	var offset = Vector2(randf_range(-64, 64), randf_range(-64, 64))
	var fire_pos = global_position + offset
	var fire = fire_scene.instantiate()
	fire.global_position = fire_pos
	get_tree().current_scene.add_child(fire)


func _on_scare_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
			body.initiate_scared(global_position)
