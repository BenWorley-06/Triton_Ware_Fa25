extends Area2D
class_name BuildArea

func get_random_point() -> Vector2:
	var shape = $CollisionShape2D.shape
	if shape is RectangleShape2D:
		var half_size = shape.size * 0.5
		# random point within rectangle centered on (0,0)
		var local_point = Vector2(
			randf_range(-half_size.x, half_size.x),
			randf_range(-half_size.y, half_size.y)
		)
		return to_global(local_point)
	else:
		push_warning("BuildArea shape must be a RectangleShape2D")
		return global_position
