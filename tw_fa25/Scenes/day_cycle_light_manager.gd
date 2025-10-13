extends Node

@onready var env: WorldEnvironment = $"../../WorldEnvironment"

var time_of_day := 0.5
@export var day_cycle_speed := 0.02  # how fast the day advances (per second)

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta * day_cycle_speed, 1.0)
	set_time_of_day(time_of_day)
var last_ambient_color := Color(0,0,0)
var last_ambient_energy := 0.0

func set_time_of_day(t: float) -> void:
	var night_color = Color(0.5, 0.6, 1.0)
	var day_color  = Color(1.0, 0.9, 0.75)

	var new_color = night_color.lerp(day_color, t)
	var new_energy = lerp(0.4, 1.0, t)

	if new_color != last_ambient_color:
		env.environment.ambient_light_color = new_color
		last_ambient_color = new_color

	if new_energy != last_ambient_energy:
		env.environment.ambient_light_energy = new_energy
		last_ambient_energy = new_energy
