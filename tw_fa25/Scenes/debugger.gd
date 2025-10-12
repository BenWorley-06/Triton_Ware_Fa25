extends Node

@onready var people_manager = get_node("/root/Game/Managers/PopulationManager")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		people_manager.request_stork()
