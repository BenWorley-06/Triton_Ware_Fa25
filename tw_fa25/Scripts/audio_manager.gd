extends Node
@onready var music: AudioStreamPlayer = $Music
@onready var death: AudioStreamPlayer = $death
@onready var good_death = preload("res://Sounds/good_death.mp3")
@onready var bad_death = preload("res://Sounds/bad_death.mp3")

func play_death(good: bool):
	if good:
		death.stream=good_death
	else:
		death.stream=bad_death
	death.play()
