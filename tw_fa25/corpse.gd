extends Area2D
@export var blood_scene: PackedScene
func smash():
	var blood=blood_scene.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
			body.initiate_scared(global_position,true)
