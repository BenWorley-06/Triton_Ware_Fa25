extends Node2D

@export var stats: GameStats
@export var overlay: ColorRect   # Full-screen ColorRect

# Define colors for different times of day
var morning_color: Color = Color(0.2, 0.3, 0.5, 0.5)  # bluish and darker
var afternoon_color: Color = Color(1.0, 0.6, 0.2, 0.3)  # orange, darker
var evening_color: Color = Color(0.1, 0.05, 0.2, 0.6)  # dark purple/blue
var night_color: Color = Color(0, 0, 0.1, 0.7)        # darkest blue

var day_timer: float = 0
var day: int = 0

func _process(delta: float) -> void:
	day_timer += delta
	if day_timer >= stats.time_in_day:
		end_day()
	
	var t = day_timer / stats.time_in_day  # 0.0 - 1.0 progress
	
	# Choose which two colors to interpolate between
	var c1: Color
	var c2: Color
	var local_t: float

	if t < 0.25:
		# Morning -> Afternoon
		c1 = morning_color
		c2 = afternoon_color
		local_t = t / 0.25
	elif t < 0.5:
		# Afternoon -> Evening
		c1 = afternoon_color
		c2 = evening_color
		local_t = (t - 0.25) / 0.25
	elif t < 0.75:
		# Evening -> Night
		c1 = evening_color
		c2 = night_color
		local_t = (t - 0.5) / 0.25
	else:
		# Night -> Morning
		c1 = night_color
		c2 = morning_color
		local_t = (t - 0.75) / 0.25

	overlay.color = c1.lerp(c2, local_t)

func end_day():
	day += 1
	day_timer = 0
