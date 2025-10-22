extends Sprite2D

@export var direction: int = 1
@export var speed: float = 200
@export var max_speed: float = 1600
@export var acceleration: float = 500 
@export var wait: float = 0

var timer: float = 0

func _process(delta: float) -> void:
	timer += delta
	if timer >= wait:
		speed = min(speed + acceleration * delta, max_speed)
		global_position.x += direction * speed * delta
		
	if global_position.x < -400 or global_position.x > 1800:
		queue_free()
