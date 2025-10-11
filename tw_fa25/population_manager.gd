extends Node

class_name PopulationManager

@onready var building_manager: BuildingManager = $"../BuildingManager"
@onready var resource_manager: ResourceManager = $"../ResourceManager"

var people: Array = []          # all active people
var jobs: Array = []            # all open jobs

func _process(delta: float) -> void:
	add_house_request()

func register_character(character: Character):
	if character not in people:
		people.append(character)

func add_job(job):
	jobs.append(job)
	
func add_house_request()->void:
	if building_manager.get_available_housing_capacity(resource_manager.population)<=0:
		var job = Build_Job.new()
		job.type="build"
		job.scene=preload("res://Scenes/Buildings/house.tscn")
		add_job(job)

func request_job(person):
	for job in jobs:
		jobs.erase(job)
		print("job recieved")
		return job
	return {}
