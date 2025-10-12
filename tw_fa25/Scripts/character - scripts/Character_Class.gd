extends Entity
class_name Character

@export var stats: Character_Stats
@onready var sprite: Sprite2D = $Sprite
@onready var voicebox: AudioStreamPlayer2D = $voicebox
@onready var sfx: AudioStreamPlayer2D = $SFX

@export var lava_particle_scene: PackedScene
@export var blood_particle_scene: PackedScene
@export var death_noise_scene: PackedScene

enum Action_State {IDLE,WORKING,CARRIED,KILLING,SlEEPING,BREEDING}
var sins=["kill","sleep"]
var action_state = Action_State.IDLE
var current_job=null

@export var sinner: bool = false
@export var fed: bool = false

var sin_timer:float = 0
var time_to_sin: float = 0

var wander_timer: float = 0
var wander_direction: Vector2 = Vector2.ZERO

var build_timer: float = 0

var farm_timer: float = 0

var selected = false
var base_scale: Vector2

var over_volcano: bool = false

var breeding_target: Character
var primary_breeder: bool = false
var breeding_timer: float = 0

var murder_target: Character
var killing_timer: float = 0

var sleeping_timer: float = 0

#	--- Main ---
func _ready():
	# register self to population manager
	base_scale = sprite.scale
	get_node("/root/Game/Managers/PopulationManager").register_character(self)
	z_index=1
		
func _process(delta: float) -> void:
	
	match action_state:
		Action_State.IDLE:
			idle(delta)
		Action_State.WORKING:
			working(delta)
		Action_State.KILLING:
			do_killing(delta)
		Action_State.SlEEPING:
			do_sleep(delta)
		Action_State.BREEDING:
			do_breed(delta)
	if not selected:
		if over_volcano:
			enter_volcano()
		move_and_slide()

#	--- Idle ---
func idle(delta: float):
	if wander_timer<=0:
		wander_timer=stats.wander_time
		var angle = randf() * TAU  # TAU = 2 * PI
		wander_direction = Vector2.from_angle(angle)
	velocity=wander_direction*stats.wander_speed
	wander_timer-=delta
	if sinner:
		sin_timer+=delta
		if sin_timer>= time_to_sin:
			initiate_sins()
			sin_timer=0
			time_to_sin=stats.max_time_to_sin*randf()
			return
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
		"farm":
			go_harvest(delta)
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
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		build_timer += delta
		if build_timer >= scaffold.build_time:
			print("job done")
			scaffold.complete_building()
			current_job = null
			action_state = Action_State.SlEEPING
			build_timer=0
			sfx.request_play("build")
			
func go_harvest(delta):
	var farm = current_job.farm
	if farm == null or not is_instance_valid(farm):
		# farm was removed for some reason
		current_job = null
		action_state = Action_State.IDLE
		return
	var distance = global_position.distance_to(farm.global_position)
	if distance > stats.distance_to_harvest:
		var direction = (farm.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		farm_timer+=delta
		if farm_timer>= stats.time_to_harvest:
			farm.harvest()
			current_job = null
			action_state = Action_State.SlEEPING
			farm_timer=0
			sfx.request_play("harvest")
	
#	--- Draging ---
func initiate_grab():
	selected = true
	get_node("CollisionShape2D").disabled = true
	z_index = 10
	var tween1 = create_tween()	
	var tween2 = create_tween()
	tween1.tween_property(sprite, "scale",base_scale * 2, 0.4) # scale up over 0.2s
	tween2.tween_property(sprite, "position:y", -100, 0.4) # move sprite up a bit
	voicebox.request_play("pickup")
	
func end_grab():
	selected = false
	get_node("CollisionShape2D").disabled = false
	z_index = 1
	var tween1 = create_tween()
	var tween2 = create_tween()
	# tween has to be same length or greater to stop bug
	tween1.tween_property(sprite, "scale", base_scale, 0.4) # return to normal size over 0.2s
	tween2.tween_property(sprite, "position:y", 0, 0.4) # move back down
	
#--- killing them ---
func enter_volcano():
	var lava = lava_particle_scene.instantiate()
	get_tree().current_scene.add_child(lava)
	lava.global_position = global_position
	killed()
	
func _on_burn_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("volcano"):
		over_volcano=true

func _on_burn_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("volcano"):
		over_volcano=false

func killed():
	if sinner:
		get_node("/root/Game/Managers/ResourceManager").add_faith(10)
	else:
		get_node("/root/Game/Managers/ResourceManager").add_faith(-20)
	var noise=death_noise_scene.instantiate()
	get_tree().current_scene.add_child(noise)
	noise.global_position=global_position
	get_node("/root/Game/Managers/PopulationManager").remove_character(self)
	queue_free()
	
func smashed():
	var blood=blood_particle_scene.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	killed()

#	--- Breeding ---
func breed(target: Character, primary: bool):
	breeding_target=target
	primary_breeder=primary
	action_state=Action_State.BREEDING

func do_breed(delta):
	if breeding_target==null:
		action_state=Action_State.IDLE
		return
	var distance = global_position.distance_to(breeding_target.global_position)
	if distance > stats.breeding_distance:
		var direction = (breeding_target.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		breeding_timer+=delta
		if primary_breeder and breeding_timer>=stats.time_to_breed:
			get_node("/root/Game/Managers/PopulationManager").request_stork()
			breeding_target.action_state=Action_State.IDLE
			breeding_target.fed=false
			action_state=Action_State.IDLE
			breeding_timer=0
			fed=false

# ------- SINS -----
func initiate_sins():
	var sin: String =sins[randi() % sins.size()]
	if sin=="kill":
		initiate_murder()
	elif sin=="sleep":
		action_state=Action_State.SlEEPING

func initiate_murder():
	murder_target=get_node("/root/Game/Managers/PopulationManager").get_random_person(self)
	if murder_target:
		action_state=Action_State.KILLING
		
func do_killing(delta):
	if murder_target==null:
		action_state=Action_State.IDLE
		return
		
	var distance = global_position.distance_to(murder_target.global_position)
	if distance > stats.murder_distance:
		var direction = (murder_target.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		killing_timer+=1
		if killing_timer>=stats.murder_time:
			murder_target.smashed()
			killing_timer=0
			murder_target=null
			action_state=Action_State.IDLE
			
func do_sleep(delta):
	velocity=Vector2.ZERO
	sleeping_timer+=delta
	if sleeping_timer>=stats.sleep_time:
		action_state=Action_State.IDLE
		sleeping_timer=0
