extends Node2D

@export var speed = 10
@export var min_spawn_x: int = 400
@export var max_spawn_x: int = 900
@export var character_scene: PackedScene
@onready var people_manager = get_node("/root/Game/Managers/PopulationManager")

var spawn_x: int = 0
var spawned: bool=false

func _ready() -> void:
	spawn_x=randi_range(min_spawn_x,max_spawn_x)
	z_index=100
	
func _process(delta: float) -> void:
	global_position.x-=speed*delta
	if global_position.x<=spawn_x and not spawned:
		drop_baby()
		spawned=true
	elif global_position.x<-200:
		queue_free()
		
func drop_baby():
	var baby = character_scene.instantiate()
	get_tree().current_scene.add_child(baby)
	baby.global_position=global_position
	people_manager.register_character(baby)
	
