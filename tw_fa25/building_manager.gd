extends Node
class_name BuildingManager

@onready var build_area: BuildArea = $"../../BuildArea"
@export var people_per_house:int =5
var houses: Array = []
var farms: Array = []

func register_house(house: Node):
		houses.append(house)

func get_total_housing_capacity() -> int:
	return houses.size() * people_per_house

func get_available_housing_capacity(current_population: int) -> int:
	return max(0, get_total_housing_capacity() - current_population)
