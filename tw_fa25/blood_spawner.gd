extends Node2D
@export var blood_spot_scene: PackedScene

@export var lifetime:float = 0.5
@export var spawn_time:float = 0.15
var spawn_timer: float = 0

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	
func _process(delta: float) -> void:
	spawn_timer+=delta
	if spawn_timer>=spawn_time:
		spawn_timer=0
		var blood = blood_spot_scene.instantiate()
		get_tree().current_scene.add_child(blood)
		blood.global_position=global_position
