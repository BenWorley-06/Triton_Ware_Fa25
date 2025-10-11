extends Entity

class_name Character

enum Action_State {IDLE,WORKING,CARRIED}

@onready var interact_area: Area2D = $"Interact Area"

@export var stats: Character_Stats
var action_state = Action_State.IDLE
var current_job=null

var wander_timer: float = 0
var wander_direction: Vector2 = Vector2.ZERO

<<<<<<< Updated upstream
var selected = false

=======
var build_timer: float = 0
>>>>>>> Stashed changes

func _ready():
	# register self to population manager
	get_node("/root/Game/Managers/PopulationManager").register_character(self)
	get_node("/root/Game/Managers/ResourceManager").add_population(1)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("left_click"):
		selected = false;
		
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 100 * delta);
		get_node("CollisionShape2D").disabled = true
		z_index = 10
	else:
		get_node("CollisionShape2D").disabled = false
func _process(delta: float) -> void:
	
	match action_state:
		Action_State.IDLE:
			idle(delta)
		Action_State.WORKING:
			working(delta)
	if not selected:
		move_and_slide()

func idle(delta: float):
	if wander_timer<=0:
		wander_timer=stats.wander_time
		var angle = randf() * TAU  # TAU = 2 * PI
		wander_direction = Vector2.from_angle(angle)
	velocity=wander_direction*stats.walk_speed
	wander_timer-=delta
	var job = get_node("/root/Game/Managers/PopulationManager").request_job(self)
	if job:
		assign_job(job)

func is_idle() -> bool:
	return action_state==Action_State.IDLE
	
func assign_job(job):
	current_job = job
	action_state=Action_State.WORKING
	
func working(delta:float):
	match current_job.type:
		"build":
			do_build_job(delta)
		_:
			print("Unknown job type:", current_job.type)
			action_state = Action_State.IDLE
			current_job = null
			
func do_build_job(delta: float) -> void:
<<<<<<< Updated upstream
	var manager = get_node("/root/Game/Managers/BuildingManager")
	var pos = manager.find_valid_build_spot(current_job.scene)
	print("working")
	if pos:
		manager.place_building(current_job.scene, pos)
	print("Built structure at", pos)
	current_job = null
	action_state = Action_State.IDLE

# drag controller
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		selected = true
	
	pass # Replace with function body.
=======
	var scaffold = current_job.scafold
	if scaffold == null or not is_instance_valid(scaffold):
		# scaffold was removed for some reason
		current_job = null
		action_state = Action_State.IDLE
		return

	var distance = global_position.distance_to(scaffold.global_position)
	if distance > 100:
		var direction = (scaffold.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed*2
	else:
		velocity = Vector2.ZERO
		build_timer += delta
		if build_timer >= scaffold.build_time:
			print("job done")
			scaffold.complete_building()
			current_job = null
			action_state = Action_State.IDLE
>>>>>>> Stashed changes
