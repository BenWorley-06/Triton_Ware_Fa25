extends Node2D
class_name AbilityManager

@onready var building_manager: BuildingManager = $"../BuildingManager"
@export var demolisher_scene: PackedScene
@export var house_marker_scene: PackedScene
@export var farm_marker_scene: PackedScene

enum AbilityChosen { PICKUP , HOUSE , FARM, DESTROY, MARKER}

var abilitychosen: AbilityChosen = AbilityChosen.PICKUP
var grabbed_character: Character = null
var click_in_progress := false

var demolisher: Area2D
var marker: Node2D

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
		AbilityChosen.MARKER:
			handle_sin_marker_input()
	
func switch_abilities():
	if Input.is_action_just_pressed("p"):
		init_pickup()
	elif Input.is_action_just_pressed("b"):
		init_house()
	elif Input.is_action_just_pressed("f"):
		init_farm()
	elif Input.is_action_just_pressed("d"):
		init_demolisher()
	elif Input.is_action_just_pressed("m"):
		init_sin_marker()

func signal_change(ability_name: String):
	match ability_name:
		"pickup":
			init_pickup()
		"house":
			init_house()
		"farm":
			init_farm()
		"destroy":
			init_demolisher()
		"marker":
			init_sin_marker()

func mouse_collision_player()->Character:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15  # <-- increase to make it easier to grab
	query.shape = shape
	query.transform = Transform2D(0, mouse_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query, 32)  # up to 32 results

	for result in results:
		var collider = result["collider"]
		if collider is Character:
			return collider
	return null

#	--- Pickup Functionality ---
func init_pickup():
	abilitychosen=AbilityChosen.PICKUP
	remove_demolisher_if_exists()
	destroy_marker()

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
	var player = mouse_collision_player()
	if player:
		grabbed_character = player
		player.initiate_grab()
		return

	click_in_progress = false

# Sin Marker
func init_sin_marker():
	abilitychosen=AbilityChosen.MARKER
	remove_demolisher_if_exists()
	destroy_marker()

func handle_sin_marker_input():
	if Input.is_action_just_pressed("left_click"):
		try_marker_character()

func try_marker_character() -> void:
	var player = mouse_collision_player()
	if player:
		player.toggle_sin_marker()
		return

#	--- Building Functionality ---
func destroy_marker():
	if marker and is_instance_valid(marker):
		marker.queue_free()
		marker = null

func init_house():
	abilitychosen=AbilityChosen.HOUSE
	remove_demolisher_if_exists()
	destroy_marker()
	var new_marker = house_marker_scene.instantiate()
	marker=new_marker
	get_tree().current_scene.add_child(new_marker)
	new_marker.global_position=get_global_mouse_position()
	

func handle_house_input(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var position=get_global_mouse_position()
		building_manager.place_scaffold(position)
		
func init_farm():
	abilitychosen=AbilityChosen.FARM
	remove_demolisher_if_exists()
	destroy_marker()
	var new_marker = farm_marker_scene.instantiate()
	marker=new_marker
	get_tree().current_scene.add_child(new_marker)
	new_marker.global_position=get_global_mouse_position()

func handle_farm_input(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var position=get_global_mouse_position()
		building_manager.place_farm(position)
		
# --- DESTROY FUNCTIONALITY ---
func init_demolisher():
	abilitychosen=AbilityChosen.DESTROY
	remove_demolisher_if_exists()
	destroy_marker()
	create_demolisher()
	
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
