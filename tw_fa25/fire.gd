extends Area2D
class_name Fire

@onready var game = get_node("/root/Game")
@export var lifetime: float = 5.0
@export var spread_time: float = 3
@onready var building_manager = get_node("/root/Game/Managers/BuildingManager")

var left_bound=0
var right_bound=1200
var up_bound=0
var lower_bound=700

var timer: float = 0
var spread_timer: float = 0
func _ready() -> void:
	game.fires+=1
	spread_time=spread_time*randf_range(0.5,2)
	if global_position.x>right_bound or global_position.x<left_bound or global_position.y>lower_bound or global_position.y<up_bound:
		queue_free()

func _process(delta: float) -> void:
	timer+=delta
	spread_timer+=delta
	if game.day==6:
		spread_timer+=delta*0.8
	if timer>=lifetime:
		queue_free()

	# occasionally spread
	if spread_timer>=spread_time:
		if game.fires<game.max_fires:
			spread_fire()
		spread_timer=0
		
func spread_fire() -> void:
	var distance = 64  # fixed distance between fires
	var angle = randf() * TAU  # random direction in radians (0 to 2π)

	var offset = Vector2(cos(angle), sin(angle)) * distance
	var fire_pos = global_position + offset

	var new_fire = load("res://Scenes/Hazards/fire.tscn").instantiate()
	new_fire.global_position = fire_pos
	get_tree().current_scene.add_child(new_fire)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('character'):
		body.enter_volcano()
	if body.is_in_group("house"):
		building_manager.destroy_building(body)


func _on_scare_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
			body.initiate_scared(global_position)
			
func _exit_tree() -> void:
	game.fires-=1
