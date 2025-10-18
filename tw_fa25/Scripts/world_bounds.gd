extends StaticBody2D

var bounds: Rect2

func _ready() -> void:
	await get_tree().process_frame # wait for all boundary nodes to enter scene
	bounds = Rect2(Vector2.ZERO,Vector2(1000,640))
	
func get_world_bounds() -> Rect2:
	var left = INF
	var right = -INF
	var top = INF
	var bottom = -INF

	var boundaries = get_tree().get_nodes_in_group("world_boundaries")
	if boundaries.is_empty():
		push_warning("No world boundaries found yet! Returning default bounds.")
		return Rect2(Vector2.ZERO, Vector2(1024, 1024)) # fallback rect

	for shape_node in boundaries:
		if shape_node is CollisionShape2D and shape_node.shape is WorldBoundaryShape2D:
			var normal = shape_node.shape.normal
			var pos = shape_node.global_position

			# detect vertical walls
			if abs(normal.x) > 0.9:
				if normal.x > 0:
					right = max(right, pos.x)
				else:
					left = min(left, pos.x)
			# detect horizontal walls
			elif abs(normal.y) > 0.9:
				if normal.y > 0:
					bottom = max(bottom, pos.y)
				else:
					top = min(top, pos.y)

	# sanity check: if any remain INF, boundaries are incomplete
	if [left, right, top, bottom].has(INF) or [left, right, top, bottom].has(-INF):
		push_warning("Incomplete or invalid boundaries detected! Using fallback bounds.")
		return Rect2(Vector2.ZERO, Vector2(1024, 1024))

	# make sure width/height are positive
	var size = Vector2(max(1.0, right - left), max(1.0, bottom - top))
	return Rect2(Vector2(left, top), size)
