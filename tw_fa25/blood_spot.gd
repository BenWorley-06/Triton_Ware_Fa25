extends Node2D
@export var lifetime:float=3

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()
