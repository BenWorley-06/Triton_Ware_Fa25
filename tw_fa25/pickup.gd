extends Node2D
class_name Pickup

@onready var resource_manager = get_node("/root/Game/Managers/ResourceManager")
@export var audio_scene: PackedScene
@onready var bread: Sprite2D = $bread
@onready var faith: Sprite2D = $faith

@export var friction: float = 10
@export var initial_speed: float = 20
@export var speed: float = 10
@export var pickup_distance: float = 90.0      # distance for attraction
@export var collect_distance: float = 12.0      # distance for collection

var velocity: Vector2 = Vector2.ZERO
var moving: bool = false

var _pickup_type: String
var pickup_type: String:
	set(value):
		_pickup_type = value
		_update_visuals()
	get:
		return _pickup_type


func _ready() -> void:
	var angle = randf() * TAU
	velocity = Vector2.from_angle(angle) * initial_speed
	_update_visuals()


func _update_visuals():
	if not is_inside_tree():
		return
	bread.visible = _pickup_type == "bread"
	faith.visible = _pickup_type == "faith"


func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var dist_to_mouse = global_position.distance_to(mouse_pos)

	# Start moving if close enough
	if dist_to_mouse < pickup_distance:
		moving = true
	else:
		moving = false

	# Move toward mouse if moving
	if moving:
		global_position = global_position.lerp(mouse_pos, speed * delta)
	else:
		# natural drift/slowdown
		if velocity.length() > 0.1:
			global_position += velocity * delta
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Check for collection
	if dist_to_mouse < collect_distance:
		_collect()


func _collect() -> void:
	match _pickup_type:
		"bread":
			resource_manager.add_bread(1)
		"faith":
			resource_manager.add_faith(1)
	var sound = audio_scene.instantiate()
	get_tree().current_scene.add_child(sound)
	queue_free()
