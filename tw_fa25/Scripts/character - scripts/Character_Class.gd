extends Entity
class_name Character

@export var stats: Character_Stats
@onready var sprite: Sprite2D = $Sprite

enum Action_State {IDLE,WORKING,CARRIED}
var action_state = Action_State.IDLE
var current_job=null

var wander_timer: float = 0
var wander_direction: Vector2 = Vector2.ZERO

var build_timer: float = 0

var selected = false
var base_scale: Vector2

#	--- Main ---
func _ready():
	# register self to population manager
	base_scale = sprite.scale
	get_node("/root/Game/Managers/PopulationManager").register_character(self)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("left_click"):
		end_grab()
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 40 * delta);
		
func _process(delta: float) -> void:
	
	match action_state:
		Action_State.IDLE:
			idle(delta)
		Action_State.WORKING:
			working(delta)
	if not selected:
		move_and_slide()

#	--- Idle ---
func idle(delta: float):
	if wander_timer<=0:
		print("changed")
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
	
#	--- Work ---
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
#	--- Draging ---
# drag controller
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		initiate_grab()
		
func initiate_grab():
	selected = true
	get_node("CollisionShape2D").disabled = true
	z_index = 10
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(sprite, "scale", sprite.scale * 2, 0.4) # scale up over 0.2s
	tween2.tween_property(sprite, "position:y", sprite.position.y - 100, 0.4) # move sprite up a bit
	
func end_grab():
	selected = false
	get_node("CollisionShape2D").disabled = false
	z_index = 1
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(sprite, "scale", base_scale, 0.2) # return to normal size over 0.2s
	tween2.tween_property(sprite, "position:y", 0, 0.2) # move back down
