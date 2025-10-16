extends Entity
class_name Character

@export var stats: Character_Stats
@onready var sprite: Sprite2D = $Sprite
@onready var voicebox: AudioStreamPlayer2D = $voicebox
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var nametag: Label = $nametag

@export var lava_particle_scene: PackedScene
@export var blood_particle_scene: PackedScene
@export var death_noise_scene: PackedScene
@export var corpse_scene: PackedScene

@onready var population_manager: PopulationManager = get_node("/root/Game/Managers/PopulationManager")
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")
@onready var building_manager: BuildingManager = get_node("/root/Game/Managers/BuildingManager")

enum Action_State {IDLE,WORKING,CARRIED,KILLING,SlEEPING,BREEDING,TALKING,SCARED}
var sins=["kill","sleep"]
var action_state = Action_State.IDLE
var current_job=null

@export var sinner: bool = false
@export var fed: bool = false
var has_sinned=false
var prophet: bool = false

var sin_timer:float = 20
var time_to_sin: float = 0

var wander_timer: float = 0
var wander_direction: Vector2 = Vector2.ZERO
var social: bool = false
var social_timer: float = 0

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

var talking_timer: float = 0

var scared_timer: float = 0

var char_name: String

#	--- Main ---
func _ready():
	# register self to population manager
	base_scale = sprite.scale
	get_node("/root/Game/Managers/PopulationManager").register_character(self)
	z_index=1
	social=randf()<0.5
	if prophet:
		social = true
	social_timer=randf_range(5,20)
	
func change_name(input_name:String):
	char_name=input_name
	nametag.text=char_name
	
func _process(delta: float) -> void:
	if not prophet:
		social_timer+=delta
		if social_timer<=0:
			social = not social
			social_timer=randf_range(5,20)
	elif not social:
		social=true

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
		Action_State.TALKING:
			do_talk(delta)
		Action_State.SCARED:
			do_scared(delta)
	if not selected:
		if over_volcano:
			enter_volcano()
		move_and_slide()

#	--- Idle ---
func idle(delta: float):
	var pop_manager = get_node("/root/Game/Managers/PopulationManager")

	# --- handle wander timer ---
	if wander_timer <= 0:
		wander_timer = stats.wander_time + randf_range(-1.0, 1.0)

		var turn_angle = randf_range(-PI / 6, PI / 6)
		var new_angle = wander_direction.angle() + turn_angle
		var new_dir = Vector2.from_angle(new_angle)

		wander_direction = wander_direction.lerp(new_dir, 0.3).normalized()
	else:
		wander_timer -= delta

	# --- social or independent movement bias ---
	if social:
		var nearby_people = []
		for c in pop_manager.people:
			if c == self or not is_instance_valid(c):
				continue
			var dist = global_position.distance_to(c.global_position)
			if dist < 150:
				nearby_people.append(c)

		if nearby_people.size() > 0:
			var avg_pos = Vector2.ZERO
			for p in nearby_people:
				avg_pos += p.global_position
			avg_pos /= nearby_people.size()

			var to_group = (avg_pos - global_position).normalized()
			wander_direction = wander_direction.lerp(to_group, 0.05).normalized()
	else:
		# while alone, drift slightly away from nearby people
		for c in pop_manager.people:
			if c == self or not is_instance_valid(c):
				continue
			var dist = global_position.distance_to(c.global_position)
			if dist < 100:
				var away = (global_position - c.global_position).normalized()
				wander_direction = wander_direction.lerp(away, 0.02).normalized()
	
	var target_velocity = wander_direction * stats.wander_speed
	velocity = velocity.lerp(target_velocity, delta * 2.0)

	# --- sinner logic ---
	if sinner:
		sin_timer += delta
		if sin_timer >= time_to_sin:
			initiate_sins()
			sin_timer = 0
			time_to_sin = stats.max_time_to_sin * randf()
			return

	# --- job or social talking ---
	if not sinner and not prophet:
		var job = pop_manager.request_job(self)
		if job:
			assign_job(job)
			return
	if social:
		if randf() < 0.001:
			action_state = Action_State.TALKING
			voicebox.request_play("talk")
			velocity = Vector2.ZERO

func is_idle() -> bool:
	return action_state==Action_State.IDLE
	
func do_talk(delta):
	talking_timer+=delta
	if talking_timer>stats.talk_timer:
		talking_timer=0
		action_state=Action_State.IDLE
		
func interupted(sent:bool=false):
	if current_job:
		if current_job.type=="farm":
			var farm = current_job.farm
			var job = Farm_Job.new()
			job.farm = farm
			population_manager.add_job(job)
		elif current_job.type=="build":
			var scafold = current_job.scafold
			var job = Build_Job.new()
			job.scafold = scafold
			population_manager.add_job(job)
		current_job=null
	if breeding_target:
		if not sent:
			breeding_target.interupted(true)
			breeding_target.action_state=Action_State.IDLE
		breeding_timer=0
		primary_breeder=false
		breeding_target = null
		

#	--- Scared ---
func initiate_scared(pos: Vector2, corpse: bool = false):
	if action_state!=Action_State.SCARED:
		interupted()
		velocity = (global_position - pos).normalized() * stats.run_speed
		action_state=Action_State.SCARED
		voicebox.request_play("scream")
	
func do_scared(delta:float):
	scared_timer+=delta
	if scared_timer>=stats.time_scared:
		action_state=Action_State.IDLE
		scared_timer=0

#	--- Work ---
func assign_job(job):
	current_job = job
	action_state=Action_State.WORKING

func working(delta:float):
	if current_job==null:
		action_state=Action_State.IDLE
		return
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
	killed(false)
	
func _on_burn_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("volcano"):
		over_volcano=true

func _on_burn_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("volcano"):
		over_volcano=false

func killed(good: bool):
	interupted()
	if not good:
		if has_sinned:
			get_node("/root/Game/Managers/ResourceManager").add_faith(10)
			get_node("/root/Game/Managers/AudioManager").play_death(true)
		else:
			get_node("/root/Game/Managers/ResourceManager").add_faith(-20)
			get_node("/root/Game/Managers/AudioManager").play_death(false)
	if good and not has_sinned:
		resource_manager.add_faith(-5)
	var noise=death_noise_scene.instantiate()
	get_tree().current_scene.add_child(noise)
	noise.global_position=global_position
	get_node("/root/Game/Managers/PopulationManager").remove_character(self)
	queue_free()
	
func smashed():
	var blood=blood_particle_scene.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	killed(false)

func murdered():
	var blood=blood_particle_scene.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	var corpse=corpse_scene.instantiate()
	get_tree().current_scene.add_child(corpse)
	corpse.global_position = global_position
	killed(true)

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
	murder_target=get_node("/root/Game/Managers/PopulationManager").get_murder_target(self)
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
			murder_target.murdered()
			killing_timer=0
			murder_target=null
			action_state=Action_State.IDLE
			has_sinned=true
			
func do_sleep(delta):
	velocity=Vector2.ZERO
	sleeping_timer+=delta
	if sleeping_timer>=stats.sleep_time:
		action_state=Action_State.IDLE
		sleeping_timer=0
