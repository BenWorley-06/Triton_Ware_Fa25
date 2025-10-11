extends Node2D
class_name AbilityManager

enum AbilityChoosen {PICKUP}

var abilitychoosen:AbilityChoosen = AbilityChoosen.PICKUP

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		match abilitychoosen:
			AbilityChoosen.PICKUP:
				try_pickup_character()

func try_pickup_character() -> void:
	var mouse_pos =get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_point(query, 1)
	for result in results:
		var collider = result["collider"]
		if collider is Character:
			collider.initiate_grab()
			return  # only grab one character
