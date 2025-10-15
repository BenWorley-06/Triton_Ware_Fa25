extends AudioStreamPlayer

func _ready() -> void:
	play()
	connect("finished", Callable(self, "_on_finished"))

func _on_finished() -> void:
	queue_free()
