extends Node2D
class_name AbilityManager

@onready var building_manager: BuildingManager = $"../BuildingManager"

enum AbilityChosen { PICKUP , HOUSE , FARM}

var abilitychosen: AbilityChosen = AbilityChosen.PICKUP
var grabbed_character: Character = null
var click_in_progress := false

func _process(delta: float) -> void:
	switch_abilities()
	match abilitychosen:
		AbilityChosen.PICKUP:
			handle_pickup_input(delta)
		AbilityChosen.HOUSE:
			handle_house_input(delta)
		AbilityChosen.FARM:
			handle_farm_input(delta)
			
func switch_abilities():
	if Input.is_action_just_pressed("p"):
		abilitychosen=AbilityChosen.PICKUP
	elif Input.is_action_just_pressed("b"):
		abilitychosen=AbilityChosen.HOUSE
	elif Input.is_action_just_pressed("f"):
		abilitychosen=AbilityChosen.FARM

#	--- Pickup Functionality ---
func handle_pickup_input(delta: float) -> void:
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

	# Released (always resets states cleanly)
	if Input.is_action_just_released("left_click"):
		click_in_progress = false
		if grabbed_character:
			grabbed_character.end_grab()
			grabbed_character = null

func try_pickup_character() -> void:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_point(query, 1)

	for result in results:
		var collider = result["collider"]
		if collider is Character:
			grabbed_character = collider
			collider.initiate_grab()
			return

	# If nothing was grabbed, reset so another click works immediately
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
