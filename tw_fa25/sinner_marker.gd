extends Node2D
@onready var icon: Polygon2D = $icon

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops() 
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(icon, "scale", Vector2.ONE * 30, 1.0)
	tween.tween_property(icon, "scale", Vector2.ONE * 15, 1.0)
