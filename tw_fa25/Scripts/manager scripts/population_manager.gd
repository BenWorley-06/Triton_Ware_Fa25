extends Node

class_name PopulationManager

@onready var building_manager: BuildingManager = $"../BuildingManager"
@onready var resource_manager: ResourceManager = $"../ResourceManager"

var people: Array = []          # all active people
var jobs: Array = []            # all open jobs


func register_character(character: Character):
	if character not in people:
		people.append(character)
		
func remove_character(character: Character):
	people.erase(character)
		
func get_random_person(exclude: Character) -> Character:
	var candidates = []
	for c in people:
		if c != exclude and is_instance_valid(c):
			candidates.append(c)
	if candidates.size() == 0:
		return null

	return candidates[randi() % candidates.size()]
func add_job(job):
	jobs.append(job)

func request_job(person):
	for job in jobs:
		jobs.erase(job)
		print("job recieved")
		return job
	return {}
	
func new_day():
	# Feeding
	for person in people:
		person.fed=false
	var total_food = resource_manager.bread
	var availiable_food = total_food
	for person in people:
		if availiable_food<=0:
			break
		person.fed=true
		availiable_food-=1
	#	Praying
	var pray_amount = min(building_manager.get_total_housing_capacity(),people.size())
	#	Update Resources
	resource_manager.add_bread(availiable_food-total_food)
	resource_manager.add_faith(pray_amount)
