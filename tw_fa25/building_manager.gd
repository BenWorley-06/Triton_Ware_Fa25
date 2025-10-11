extends Node
class_name BuildingManager

@export var people_per_house:int =2
@export var scafold_scene: PackedScene = preload("res://Scenes/Buildings/house_scafold.tscn")
@export var farm_scene: PackedScene = preload("res://Scenes/Buildings/farm.tscn")
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
	return houses.size() * people_per_house

func get_available_housing_capacity(current_population: int) -> int:
	return max(0, get_total_housing_capacity() - current_population)
	
func place_farm(position: Vector2) -> void:
	var farm = farm_scene.instantiate()
	farm.global_position = position
	get_tree().current_scene.add_child(farm)
	register_farm(farm)
	
func place_scaffold(position: Vector2) -> void:
	print("scafold placed")
	var scafold = scafold_scene.instantiate()
	scafold.global_position = position
	get_tree().current_scene.add_child(scafold)
	register_house_scafold(scafold)

	request_worker_for_scaffold(scafold)

func request_worker_for_scaffold(scafold: Node) -> void:
	if scafold in house_scafolds:
		house_scafolds.erase(scafold)
		var job = Build_Job.new()
		job.type="build"
		job.scafold=scafold
		get_node("/root/Game/Managers/PopulationManager").add_job(job)
