extends Node2D

@export var radius: float = 32.0
@export var thickness: float = 3.0
@export var color: Color = Color(1.0, 0.8, 0.3)
var progress: float = 0.0 # 0.0 to 1.0

func _draw() -> void:
	if progress > 0:
		var angle := progress * TAU
		draw_arc(Vector2.ZERO, radius, -PI/2, angle - PI/2, 64, color, thickness)

func set_progress(value: float) -> void:
	progress = clamp(value, 0.0, 1.0)
	queue_redraw()
