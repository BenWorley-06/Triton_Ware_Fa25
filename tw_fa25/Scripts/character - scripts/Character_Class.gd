extends Entity
class_name Character

@export var stats: Character_Stats
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var voicebox: AudioStreamPlayer2D = $voicebox
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var nametag: Label = $nametag

@export var lava_particle_scene: PackedScene
@export var blood_particle_scene: PackedScene
@export var death_noise_scene: PackedScene
@export var corpse_scene: PackedScene
@export var streak_scene: PackedScene
@export var sin_marker_scene: PackedScene
@export var blood_spawner_scene: PackedScene

@onready var bounds: Node = get_node("/root/Game/world_bounds")
@onready var population_manager: PopulationManager = get_node("/root/Game/Managers/PopulationManager")
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")
@onready var building_manager: BuildingManager = get_node("/root/Game/Managers/BuildingManager")
@onready var gui: CanvasLayer = get_node("/root/Game/GUI")

enum Action_State {IDLE,WORKING,CARRIED,KILLING,SlEEPING,BREEDING,TALKING,SCARED,STREAKING,STEALING}
var sins=["kill","sleep","streak"]
var action_state = Action_State.IDLE
var current_job=null

var map_bounds: Rect2
var sin_marker: Node2D

@export var sinner: bool = false
@export var fed: bool = false
var has_sinned=false
var prophet: bool = false

var sin_timer: float = 0
var time_to_sin: float = 30

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

var streaking_timer: float = 0
var streak_area: Area2D
var streaking: bool = false

var talking_timer: float = 0

var scared_timer: float = 0

var char_name
var can_die_timer: float = 1

var steal_target: Pickup
# --- visuals ---
var color: String
var colors: Array = ["white","grey","black"]
var walking_animation: String
var building_animation: String
var harvest_animation: String
var killing_animation: String
var streaking_animation: String
var floating_animation: String

#	--- Main ---
func _ready():
	# register self to population manager
	base_scale = sprite.scale
	get_node("/root/Game/Managers/PopulationManager").register_character(self)
	z_index=1
	social=randf()<0.5
	wander_direction = Vector2.from_angle(randf_range(0, TAU))
	if prophet:
		social = true
	social_timer=randf_range(5,20)
	await get_tree().process_frame  # ensures world and children are ready
	await get_tree().process_frame
	if bounds:
		map_bounds = bounds.bounds
	set_animations()
	
func change_name(input_name:String):
	char_name=input_name
	nametag.text=char_name
	if char_name=="Sinner":
		var tween = create_tween()
		tween = create_tween()
		tween.set_loops()  # infinite looping pulse
		tween.tween_property(nametag, "scale", Vector2(5, 5), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(nametag, "scale", Vector2(3, 3), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func set_animations():
	color = colors.pick_random()
	walking_animation=color+"-walking"
	building_animation=color+"-building"
	harvest_animation=color+"-harvest"
	killing_animation=color+"-killing"
	streaking_animation=color+"-streaking"
	sprite.play(walking_animation)
	
func update_animation():
	sprite.play()
	match action_state:
		Action_State.IDLE:
			sprite.play(walking_animation)
		Action_State.WORKING:
			sprite.play(walking_animation)
		Action_State.KILLING:
			sprite.play(walking_animation)
		Action_State.SlEEPING:
			sprite.play(walking_animation)
			sprite.stop()
	
func _process(delta: float) -> void:
	can_die_timer-=delta
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
		Action_State.STREAKING:
			do_streaking(delta)
		Action_State.STEALING:
			do_stealing(delta)
	if not selected:
		if over_volcano:
			enter_volcano()
		move_and_slide()

#	--- Idle ---
func get_wander_dir_social() -> Vector2:
	var pop_manager = get_node("/root/Game/Managers/PopulationManager")
	var nearby_people: Array = []
	for c in pop_manager.people:
		if c == self or not is_instance_valid(c):
			continue
		var dist = global_position.distance_to(c.global_position)
		if dist < 150:
			nearby_people.append(c)

	if nearby_people.is_empty():
		return wander_direction

	# --- cohesion (move toward group center) ---
	var avg_pos = Vector2.ZERO
	for p in nearby_people:
		avg_pos += p.global_position
	avg_pos /= nearby_people.size()
	var to_group = avg_pos - global_position
	if to_group.length_squared() > 0.0001:
		to_group = to_group.normalized()
	else:
		to_group = Vector2.ZERO

	# --- separation (avoid being too close) ---
	var separation = Vector2.ZERO
	for p in nearby_people:
		var diff = global_position - p.global_position
		var dist = diff.length()
		if dist < 50 and dist > 0.001:
			separation += diff.normalized() * (1.0 - dist / 50.0)

	# --- combine with weights ---
	var combined = (to_group * 0.6 + separation * 1.4)
	if combined.length_squared() > 0.0001:
		combined = combined.normalized()
	else:
		combined = wander_direction

	wander_direction = wander_direction.lerp(combined, 0.05).normalized()
	return wander_direction


func get_boundary_avoidance(map_rect: Rect2) -> Vector2:
	var avoidance = Vector2.ZERO
	var margin = 100.0
	var pos = global_position

	# Repel horizontally
	if pos.x < map_rect.position.x + margin:
		avoidance.x += 1.0 - (pos.x - map_rect.position.x) / margin
	elif pos.x > map_rect.position.x + map_rect.size.x - margin:
		avoidance.x -= 1.0 - ((map_rect.position.x + map_rect.size.x) - pos.x) / margin

	# Repel vertically
	if pos.y < map_rect.position.y + margin:
		avoidance.y += 1.0 - (pos.y - map_rect.position.y) / margin
	elif pos.y > map_rect.position.y + map_rect.size.y - margin:
		avoidance.y -= 1.0 - ((map_rect.position.y + map_rect.size.y) - pos.y) / margin

	return avoidance.normalized()
	
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
		wander_direction=get_wander_dir_social()
	var boundary_force = get_boundary_avoidance(map_bounds)

	# Combine boundary force with wander
	if boundary_force != Vector2.ZERO:
		var combined = (wander_direction + boundary_force * 2.0).normalized()
		wander_direction = wander_direction.lerp(combined, 0.1)
	
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
		update_animation()
		
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
			update_animation()
		breeding_timer=0
		primary_breeder=false
		breeding_target = null
		

#	--- Scared ---
func initiate_scared(pos: Vector2, corpse: bool = false, streaker: bool = false):
	if streaker and streaking:
		return
	if action_state!=Action_State.SCARED:
		interupted()
		velocity = (global_position - pos).normalized() * stats.run_speed
		action_state=Action_State.SCARED
		voicebox.request_play("scream")
	
func do_scared(delta:float):
	scared_timer+=delta
	if scared_timer>=stats.time_scared:
		action_state=Action_State.IDLE
		update_animation()
		scared_timer=0

#	--- Work ---
func assign_job(job):
	current_job = job
	action_state=Action_State.WORKING

func working(delta:float):
	if current_job==null:
		action_state=Action_State.IDLE
		update_animation()
		return
	match current_job.type:
		"build":
			do_build_job(delta)
		"farm":
			go_harvest(delta)
		_:
			print("Unknown job type:", current_job.type)
			action_state = Action_State.IDLE
			update_animation()
			current_job = null

func do_build_job(delta: float) -> void:
	var scaffold = current_job.scafold
	if scaffold == null or not is_instance_valid(scaffold):
		# scaffold was removed for some reason
		current_job = null
		action_state = Action_State.IDLE
		update_animation()
		return

	var distance = global_position.distance_to(scaffold.global_position)
	if distance > 100:
		var direction = (scaffold.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		if sprite.animation != building_animation:
			sprite.play(building_animation)
		build_timer += delta
		if build_timer >= scaffold.build_time:
			print("job done")
			scaffold.complete_building()
			current_job = null
			action_state = Action_State.SlEEPING
			update_animation()
			build_timer=0
			sfx.request_play("build")
			
func go_harvest(delta):
	var farm = current_job.farm
	if farm == null or not is_instance_valid(farm):
		# farm was removed for some reason
		current_job = null
		action_state = Action_State.IDLE
		update_animation()
		return
	var distance = global_position.distance_to(farm.global_position)
	if distance > stats.distance_to_harvest:
		var direction = (farm.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		farm_timer+=delta
		if sprite.animation != harvest_animation:
			sprite.play(harvest_animation)
		if farm_timer>= stats.time_to_harvest:
			farm.harvest()
			current_job = null
			action_state = Action_State.SlEEPING
			update_animation()
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
	if can_die_timer>0:
		return
	var lava = lava_particle_scene.instantiate()
	get_tree().current_scene.add_child(lava)
	lava.global_position = global_position
	killed(false)
	
func _on_burn_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("volcano"):
		over_volcano=true
		voicebox.request_play("scream")

func _on_burn_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("volcano"):
		over_volcano=false

func killed(good: bool):
	interupted()
	if not good:
		if has_sinned:
			get_node("/root/Game/Managers/ResourceManager").add_faith(20)
			get_node("/root/Game/Managers/AudioManager").play_death(true)
			gui.has_killed=true
		else:
			get_node("/root/Game/Managers/ResourceManager").add_faith(-10)
			get_node("/root/Game/Managers/AudioManager").play_death(false)
	if good and not has_sinned:
		resource_manager.add_faith(-5)
	var noise=death_noise_scene.instantiate()
	get_tree().current_scene.add_child(noise)
	noise.global_position=global_position
	get_node("/root/Game/Managers/PopulationManager").remove_character(self)
	queue_free()
	
func smashed():
	if can_die_timer>0:
		return
	var blood=blood_particle_scene.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	killed(false)

func murdered():
	if can_die_timer>0:
		return
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
		update_animation()
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
			update_animation()
			breeding_timer=0
			fed=false

# ------- SINS -----
func toggle_sin_marker():
	if not sin_marker:
		sin_marker=sin_marker_scene.instantiate()
		add_child(sin_marker)
		return
	sin_marker.queue_free()
	sin_marker=null

func initiate_sins():
	var temp_sins=sins.duplicate()
	if resource_manager.bread_pickups.size()>0:
		temp_sins.append("steal")
		
	var sin: String =temp_sins[randi() % temp_sins.size()]
	print("Available sins:", temp_sins, " → Chosen:", sin)
	if sin=="kill":
		initiate_murder()
	elif sin=="sleep":
		action_state=Action_State.SlEEPING
	elif sin=="streak":
		start_streaking()
	elif sin=="steal":
		start_stealing()

func initiate_murder():
	murder_target=get_node("/root/Game/Managers/PopulationManager").get_murder_target(self)
	if murder_target:
		action_state=Action_State.KILLING
		
func do_killing(delta):
	if murder_target==null:
		action_state=Action_State.IDLE
		update_animation()
		return
		
	var distance = global_position.distance_to(murder_target.global_position)
	if distance > stats.murder_distance:
		var direction = (murder_target.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		if sprite.animation != killing_animation:
			sprite.play(killing_animation)
		killing_timer+=delta
		if killing_timer>=stats.murder_time:
			murder_target.murdered()
			killing_timer=0
			murder_target=null
			action_state=Action_State.IDLE
			update_animation()
			has_sinned=true
			var blood_spawner = blood_spawner_scene.instantiate()
			add_child(blood_spawner)
			blood_spawner.global_position=global_position
			
func do_sleep(delta):
	velocity=Vector2.ZERO
	sleeping_timer+=delta
	if sleeping_timer>=stats.sleep_time:
		action_state=Action_State.IDLE
		update_animation()
		sleeping_timer=0

func start_streaking():
	print("streaking")
	streak_area=streak_scene.instantiate()
	add_child(streak_area)
	streak_area.global_position = global_position
	streaking=true
	action_state=Action_State.STREAKING
	has_sinned=true

func do_streaking(delta):
	if sprite.animation!=streaking_animation:
		sprite.play(streaking_animation)
	var streak_direction = get_wander_dir_social()
	var target_velocity = streak_direction * stats.run_speed
	velocity = velocity.lerp(target_velocity, delta * 2.0)
	streaking_timer+=delta
	if streaking_timer>=stats.steak_time:
		streaking_timer=0
		action_state=Action_State.IDLE
		update_animation()
		streaking=false
		streak_area.queue_free()
		streak_area=null
		
func start_stealing():
	action_state=Action_State.STEALING
	has_sinned=true
	steal_target=resource_manager.bread_pickups.pick_random()
	print("stealing")
	
func do_stealing(delta):
	if steal_target==null:
		action_state=Action_State.IDLE
		update_animation()
		return
		
	var distance = global_position.distance_to(steal_target.global_position)
	if distance > stats.steal_distance:
		var direction = (steal_target.global_position - global_position).normalized()
		velocity = direction * stats.walk_speed
	else:
		velocity = Vector2.ZERO
		steal_target.queue_free()
		if resource_manager.bread_pickups.size()>0:
			start_stealing()
