extends Node
@onready var music: AudioStreamPlayer = $Music
@onready var death: AudioStreamPlayer = $death
@onready var good_death = preload("res://Sounds/good_death.mp3")
@onready var bad_death = preload("res://Sounds/bad_death.mp3")
@onready var win = preload("res://Sounds/christian-blues-jesus-christ-church-music-349261.mp3")
@onready var lose = preload("res://Sounds/01.02. Dies Irae (Part 1) (mp3cut.net).mp3")
@onready var game = get_node("/root/Game")
@onready var win_lose: AudioStreamPlayer = $win_lose

@onready var day_7_amb: AudioStreamPlayer = $"day 7 amb"
var prev_day: int = 0
func _process(delta: float) -> void:
	if game.day==6 and prev_day!=6:
		day_7_amb.play()
	prev_day=game.day
	
func play_death(good: bool):
	if good:
		death.stream=good_death
	else:
		death.stream=bad_death
	death.play()
	
func play_win(did_win:bool):
	music.stop()
	day_7_amb.stop()
	death.stop()
	if did_win:
		win_lose.stream=win
	else:
		win_lose.stream=lose
	win_lose.play()
	if did_win:
		await get_tree().create_timer(20.0).timeout
		music.play()
