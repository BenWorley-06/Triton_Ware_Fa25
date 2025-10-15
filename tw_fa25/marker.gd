extends Node2D
class_name Marker

@export var base_speed := 400.0
@export var max_speed := 2000.0
@export var acceleration_factor := 3.0

func _process(delta: float) -> void:
	var target = get_global_mouse_position()
	var distance = global_position.distance_to(target)
	
	# Speed scales with distance (but is capped)
	var speed = clamp(base_speed + distance * acceleration_factor, base_speed, max_speed)
	
	global_position = global_position.move_toward(target, delta * speed)
