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

func find_valid_build_spot(scene: PackedScene) -> Vector2:
	var build_area = get_node("/root/Game/BuildArea")
	var space_state = build_area.get_world_2d().direct_space_state
	
	var temp_instance = scene.instantiate()
	var shape = temp_instance.get_node("CollisionShape2D").shape
	temp_instance.queue_free()  # We just needed the shape size
	var max_attempts = 50
	for i in range(max_attempts):
		var point = build_area.get_random_point()
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, point)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.collision_mask = 1 << 2
		
		var results = space_state.intersect_shape(query, 1)
		if results.is_empty():
			return point
	
	print("No valid spot found after", max_attempts, "attempts")
	return Vector2.ZERO

func place_building(scene: PackedScene, position: Vector2):
	var instance = scene.instantiate()
	instance.position = position
	get_tree().current_scene.add_child(instance)
	register_house(instance)
