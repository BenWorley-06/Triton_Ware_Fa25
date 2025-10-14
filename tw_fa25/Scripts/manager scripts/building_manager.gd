extends Node2D
class_name BuildingManager

@export var people_per_house:int =2
@export var scafold_scene: PackedScene = preload("res://Scenes/Buildings/house_scafold.tscn")
@export var farm_scene: PackedScene = preload("res://Scenes/Buildings/farm.tscn")
@onready var resource_manager: ResourceManager = $"../ResourceManager"
var house_scafolds: Array = []
var houses: Array = []
var farms: Array = []

func register_farm(farm: Node):
		farms.append(farm)

func register_house(house: Node):
		houses.append(house)
		
func register_house_scafold(house_scafold: Node):
		house_scafolds.append(house_scafold)
		
func get_total_housing_capacity() -> int:
	return (houses.size()+house_scafolds.size()) * people_per_house

func get_available_housing_capacity(current_population: int) -> int:
	return max(0, get_total_housing_capacity() - current_population)
	
func place_farm(position: Vector2) -> void:
	var farm = farm_scene.instantiate()
	farm.global_position = position
	get_tree().current_scene.add_child(farm)
	if is_colliding_with_layer(farm, 2):
		print("Farm overlaps layer 2 object — deleting.")
		farm.queue_free()
		return
	if houses.size()<farms.size()+1:
		farm.queue_free()
		return
	register_farm(farm)
	
func place_scaffold(position: Vector2) -> void:
	
	print(house_scafolds.size())
	if get_available_housing_capacity(resource_manager.population) >0:
		
		return
	var scafold = scafold_scene.instantiate()
	scafold.global_position = position
	get_tree().current_scene.add_child(scafold)
	if is_colliding_with_layer(scafold, 2):
		print("Farm overlaps layer 2 object — deleting.")
		scafold.queue_free()
		return
	register_house_scafold(scafold)

	request_worker_for_scaffold(scafold)

func request_worker_for_scaffold(scafold: Node) -> void:
	if scafold in house_scafolds:
		var job = Build_Job.new()
		job.type="build"
		job.scafold=scafold
		get_node("/root/Game/Managers/PopulationManager").add_job(job)
		
func is_colliding_with_layer(node: Node2D, layer: int) -> bool:
	var space_state = node.get_world_2d().direct_space_state

	var collider_shape: CollisionShape2D = node.find_child("CollisionShape2D", true, false)
	if collider_shape == null or collider_shape.shape == null:
		print("No collision shape on", node.name)
		return false

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = collider_shape.shape
	params.transform = collider_shape.global_transform
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = 1 << (layer - 1)

	params.exclude = [node]

	var result = space_state.intersect_shape(params, 10)
	return result.size() > 0

func destroy_building(building: Node):
	match building.type:
		"farm":
			farms.erase(building)
		"house":
			houses.erase(building)
		"scafold":
			house_scafolds.erase(building)
	building.queue_free()
