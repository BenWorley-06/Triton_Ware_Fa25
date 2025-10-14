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
