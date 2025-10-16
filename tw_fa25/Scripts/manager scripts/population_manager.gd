extends Node

class_name PopulationManager

@onready var building_manager: BuildingManager = $"../BuildingManager"
@onready var resource_manager: ResourceManager = $"../ResourceManager"
@export var stork_scene: PackedScene
@export var names: NameList
const Character = preload("res://Scripts/character - scripts/Character_Class.gd")

var people: Array = []          # all active people
var jobs: Array = []            # all open jobs
var prophet_spawned=false

var breed_timer: float = 0
var breed_cooldown: float = 10

func _ready():
	call_deferred("register_character")

func _process(delta: float) -> void:
	breed_timer+=delta
	if breed_timer>=breed_cooldown:
		assign_breeders()
		breed_timer=0

func register_character(character: Character):
	if character not in people:
		people.append(character)
		if not resource_manager:
			resource_manager= $"../ResourceManager"
		var char_name = names.name_list.pick_random()
		character.change_name(char_name)
		resource_manager.add_population(1)
		
func remove_character(character: Character):
	people.erase(character)
		
func get_murder_target(exclude: Character) -> Character:
	var candidates: Array = []
	for c in people:
		if c == exclude or not is_instance_valid(c) or c.sinner:
			continue
		candidates.append(c)

	if candidates.is_empty():
		return null

	# Find “crowd center” — average position of all people (optional)
	var center := Vector2.ZERO
	for c in candidates:
		center += c.global_position
	center /= candidates.size()

	# Compute weights based on distance from center and exclude proximity extremes
	var weights: Array = []
	for c in candidates:
		var crowd_dist = c.global_position.distance_to(center)
		var self_dist = exclude.global_position.distance_to(c.global_position)

		# Prefer characters close to others but not too close to murderer
		var weight = clamp(1.0 / (crowd_dist + 10.0), 0.0, 1.0)
		weight *= clamp(self_dist / 200.0, 0.2, 1.0)
		weights.append(weight)

	# Pick a target weighted by likelihood
	var total = weights.reduce(func(a, b): return a + b)
	var choice = randf() * total
	var accum = 0.0

	for i in range(candidates.size()):
		accum += weights[i]
		if choice <= accum:
			return candidates[i]

	return candidates.pick_random()

func add_job(job):
	jobs.append(job)

func request_job(person):
	for job in jobs:
		jobs.erase(job)
		print("job recieved")
		return job
	return {}
	
func assign_breeders():
	var person1: Character
	var person2: Character
	var people_found: int = 0
	for person in people:
		if people_found>=2:
			break
		if person.action_state==Character.Action_State.IDLE and person.fed:
			if person1:
				person2=person
			else:
				person1=person
			people_found+=1
	if person1 and person2:
		person1.breed(person2,true)
		person2.breed(person1,true)

func request_stork():
	var stork=stork_scene.instantiate()
	get_tree().current_scene.add_child(stork)
	stork.global_position.x = 1300
	stork.global_position.y = randi_range(200,400)
	
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
