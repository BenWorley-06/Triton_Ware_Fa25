extends AudioStreamPlayer2D
class_name SFX

var sound_dict: Dictionary ={}

func _ready() -> void:
	sound_dict={
		"build":preload("res://Sounds/character/SFX/house-building.mp3"),
		"harvest":preload("res://Sounds/character/SFX/plop.mp3")
	}

func request_play(name: String) -> void:
	stream = sound_dict[name]
	play()
