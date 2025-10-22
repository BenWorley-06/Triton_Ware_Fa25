extends Node2D
class_name BuildingManager

@export var people_per_house:int =2
@export var scafold_scene: PackedScene = preload("res://Scenes/Buildings/house_scafold.tscn")
@export var farm_scene: PackedScene = preload("res://Scenes/Buildings/farm.tscn")
@onready var gui: CanvasLayer = $"../../GUI"
@onready var resource_manager: ResourceManager = $"../ResourceManager"
@export var error_text_scene: PackedScene
var house_scafolds: Array = []
var houses: Array = []
var farms: Array = []

#Paths
func create_path(from: Vector2, to: Vector2) -> void:
	# Create line and style it
	var line := Line2D.new()
	line.width = 28                                # wider
	line.default_color = Color(0.65, 0.55, 0.3)
	line.z_as_relative = false
	line.z_index = -50

	# nicer caps and joints
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND

	# Add to root/current scene so points can be global coordinates
	get_tree().current_scene.add_child(line)

	# Determine how many intermediate points (higher for longer paths)
	var dist := from.distance_to(to)
	var steps = clamp(int(dist / 64), 2, 12)  # one point per ~64px, min 2, max 12

	var points: Array[Vector2] = []

	for i in range(steps + 1):
		var t = float(i) / steps
		var pos := from.lerp(to, t)

		# Do NOT add noise to endpoints
		if i > 0 and i < steps:
			# interior noise is proportional to distance so it doesn't overpower short paths
			var wiggle_strength = clamp(dist * 0.02, 8, 40)  # tune min/max
			# bias wiggle towards middle with a sin falloff
			var falloff := sin(t * PI)
			pos.y += randf_range(-1.0, 1.0) * wiggle_strength * falloff
			pos.x += randf_range(-1.0, 1.0) * (wiggle_strength * 0.3) * falloff

		points.append(pos)

	# Assign global points directly (line is child of current_scene so local==global origin)
	line.points = points


func connect_to_closest(building_position: Vector2, exempt_building: Node):
	var closest_building: Node2D = null
	var closest_dist := INF
	
	for b in houses+farms:
		var dist = building_position.distance_to(b.global_position)
		if dist < closest_dist and b != exempt_building:
			closest_dist = dist
			closest_building = b
	
	if closest_building:
		create_path(building_position, closest_building.global_position)

func register_farm(farm: Node):
		farms.append(farm)
		connect_to_closest(farm.global_position,farm)
		if gui.tutorial_active:
			gui.t_data.farms+=1

func register_house(house: Node):
		houses.append(house)
		connect_to_closest(house.global_position,house)
		if gui.tutorial_active:
			gui.t_data.houses+=1
		
func register_house_scafold(house_scafold: Node):
		house_scafolds.append(house_scafold)
		
func get_total_housing_capacity() -> int:
	return ((houses.size()+house_scafolds.size()) * people_per_house)

func get_available_housing_capacity(current_population: int) -> int:
	return max(0, get_total_housing_capacity() - current_population)

func make_error(pos: Vector2, id:String):
	var text=error_text_scene.instantiate()
	get_tree().current_scene.add_child(text)
	text.global_position = pos
	text.set_message(id)
	

func place_farm(pos: Vector2) -> void:
	var farm = farm_scene.instantiate()
	farm.global_position = pos
	get_tree().current_scene.add_child(farm)
	if is_colliding_with_layer(farm, 2):
		print("Farm overlaps layer 2 object — deleting.")
		farm.queue_free()
		make_error(pos,"loc")
		return
	if houses.size()<farms.size()+1:
		farm.queue_free()
		make_error(pos,"house")
		return
	register_farm(farm)
	
func place_scaffold(pos: Vector2) -> void:
	
	print(house_scafolds.size())
	if get_available_housing_capacity(resource_manager.population) >0:
		make_error(pos,"peeps")
		return
	var scafold = scafold_scene.instantiate()
	scafold.global_position = pos
	get_tree().current_scene.add_child(scafold)
	if is_colliding_with_layer(scafold, 2):
		print("Farm overlaps layer 2 object — deleting.")
		scafold.queue_free()
		make_error(pos,"loc")
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
