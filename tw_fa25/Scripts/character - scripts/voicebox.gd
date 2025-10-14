extends AudioStreamPlayer2D
class_name VoiceBox

@export var pickup_folder: String = "res://Sounds/Character/Pickup Edited/"
@export var talk_folder: String = "res://Sounds/character/Talk Edited 2/"
var pickup_lines: Array

var voice_lines: Dictionary ={}

func _ready() -> void:
	voice_lines["pickup"] = load_audio_files(pickup_folder)
	voice_lines["talk"] = load_audio_files(talk_folder)

func load_audio_files(path: String) -> Array:
	var dir := DirAccess.open(path)
	var files := []
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".mp3") or file_name.ends_with(".wav"): #Need to change if add different types of files
				var stream := load(path + file_name)
				if stream:
					files.append(stream)
	return files

func request_play(name: String) -> void:
	if not voice_lines.has(name):
		print("No voice line group called:", name)
		return
	var group = voice_lines[name]
	if group.size() == 0:
		print("No sounds loaded for:", name)
		return

	# Pick a random sound
	var chosen: AudioStream = group[randi() % group.size()]

	# Play it
	stream = chosen
	play()
