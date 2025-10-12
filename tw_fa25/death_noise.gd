extends AudioStreamPlayer2D

func _ready() -> void:
	play()
	# Wait until the sound finishes before freeing
	await get_tree().create_timer(stream.get_length()).timeout
	queue_free()
