extends Node2D
@export var lifetime: float = 3
@export var character_scene: PackedScene
@export var halo_scene: PackedScene
@onready var people_manager = get_node("/root/Game/Managers/PopulationManager")

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	var person = character_scene.instantiate()
	get_tree().current_scene.add_child(person)
	person.global_position = global_position
	people_manager.prophet_spawned=true
	person.prophet=true
	var halo = halo_scene.instantiate()
	person.add_child(halo)
	queue_free()
