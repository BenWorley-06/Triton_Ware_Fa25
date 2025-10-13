extends Node2D
class_name AbilityManager

@onready var building_manager: BuildingManager = $"../BuildingManager"
@export var demolisher_scene: PackedScene

enum AbilityChosen { PICKUP , HOUSE , FARM, DESTROY}

var abilitychosen: AbilityChosen = AbilityChosen.PICKUP
var grabbed_character: Character = null
var click_in_progress := false

var demolisher: Area2D

func _process(delta: float) -> void:
	switch_abilities()
	match abilitychosen:
		AbilityChosen.PICKUP:
			handle_pickup_input(delta)
		AbilityChosen.HOUSE:
			handle_house_input(delta)
		AbilityChosen.FARM:
			handle_farm_input(delta)
		AbilityChosen.DESTROY:
			handle_destroy_input(delta)
			
func switch_abilities():
	
	if Input.is_action_just_pressed("p"):
		abilitychosen=AbilityChosen.PICKUP
		remove_demolisher_if_exists()
	elif Input.is_action_just_pressed("b"):
		abilitychosen=AbilityChosen.HOUSE
		remove_demolisher_if_exists()
	elif Input.is_action_just_pressed("f"):
		abilitychosen=AbilityChosen.FARM
		remove_demolisher_if_exists()
	elif Input.is_action_just_pressed("d"):
		abilitychosen=AbilityChosen.DESTROY
		remove_demolisher_if_exists()
		create_demolisher()

#	--- Pickup Functionality ---
func handle_pickup_input(delta: float) -> void:
	# Released (always resets states cleanly)
	if Input.is_action_just_released("left_click"):
		click_in_progress = false
		if grabbed_character:
			grabbed_character.end_grab()
			grabbed_character = null
	# Fresh click attempt
	if Input.is_action_just_pressed("left_click"):
		click_in_progress = true
		if grabbed_character == null:
			try_pickup_character()

	# While holding
	if grabbed_character and Input.is_action_pressed("left_click"):
		grabbed_character.global_position = lerp(
			grabbed_character.global_position,
			get_global_mouse_position(),
			20 * delta
		)

	

func try_pickup_character() -> void:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 50  # <-- increase to make it easier to grab
	query.shape = shape
	query.transform = Transform2D(0, mouse_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query, 32)  # up to 32 results

	for result in results:
		var collider = result["collider"]
		if collider is Character:
			grabbed_character = collider
			collider.initiate_grab()
			return

	click_in_progress = false

#	--- Building Functionality ---
func handle_house_input(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var position=get_global_mouse_position()
		building_manager.place_scaffold(position)

func handle_farm_input(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var position=get_global_mouse_position()
		building_manager.place_farm(position)
		
# --- DESTROY FUNCTIONALITY ---
func create_demolisher():
	if demolisher:
		return  # already exists
	demolisher = demolisher_scene.instantiate()
	get_tree().current_scene.add_child(demolisher)
	demolisher.global_position=get_global_mouse_position()

func remove_demolisher_if_exists():
	if demolisher and is_instance_valid(demolisher):
		demolisher.queue_free()
		demolisher = null
		
func handle_destroy_input(delta: float) -> void:
	if not demolisher:
		return

	# constantly follow mouse
	demolisher.global_position = demolisher.global_position.lerp(get_global_mouse_position(), delta * 5)

	# trigger smite
	if Input.is_action_just_pressed("left_click"):
		if "smite_buildings" in demolisher:
			demolisher.smite_buildings()
