extends Node

class_name PopulationManager

@onready var building_manager: BuildingManager = $"../BuildingManager"
@onready var resource_manager: ResourceManager = $"../ResourceManager"

var people: Array = []          # all active people
var jobs: Array = []            # all open jobs

var request_house_timer:float=0

func _process(delta: float) -> void:
	pass

func register_character(character: Character):
	if character not in people:
		people.append(character)

func add_job(job):
	jobs.append(job)

func request_job(person):
	for job in jobs:
		jobs.erase(job)
		print("job recieved")
		return job
	return {}
