extends Node2D

@export var stats: GameStats

var day_timer: float = 0
var day: int = 0

func _process(delta: float) -> void:
	day_timer+=delta
	if day_timer>=stats.time_in_day:
		end_day()

func end_day():
	day+=1
	day_timer=0
