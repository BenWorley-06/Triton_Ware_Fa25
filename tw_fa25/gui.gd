extends CanvasLayer
@onready var game = get_node("/root/Game")
@onready var ability_manager = get_node("/root/Game/Managers/AbilityManager")
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")
@onready var population_manager: PopulationManager = get_node("/root/Game/Managers/PopulationManager")
@export var prophet_spawner_scene: PackedScene
@export var character_scene: PackedScene
@onready var prophet_spawn_location: Marker2D = $Prophet_Spawn_Location
@onready var white_flash: TextureRect = $"white flash"
@onready var day_counter: AnimatedSprite2D = $Indicators/day_counter


@onready var button_container: MarginContainer = $button_container
@onready var pickup_button: Button = $MarginContainer/VBoxContainer/PickupButton
@onready var destroy_button: Button = $MarginContainer/VBoxContainer/DestroyButton
@onready var house_button: Button = $MarginContainer/VBoxContainer/HouseButton
@onready var farm_button: Button = $MarginContainer/VBoxContainer/FarmButton
@onready var marker_button: Button = $button_container/VBoxContainer/MarkerButton

@onready var indicators: Node2D = $Indicators
@onready var population: Label = $Indicators/HBoxContainer/Population
@onready var bread: Label = $Indicators/HBoxContainer/Bread
@onready var faith_bar: TextureProgressBar = $Indicators/faith_bar

@export var t_data: TutorialData
@onready var tutorial_container: MarginContainer = $tutorial_container
@onready var t_ob: Label = $tutorial_container/VBoxContainer/t_ob
@onready var t_dir: Label = $tutorial_container/VBoxContainer/t_dir
@onready var t_prog: Label = $tutorial_container/VBoxContainer/t_prog
@onready var skip_tutorial: Button = $skip_tutorial

@export var button_offset: float = 100.0
@export var tween_time: float = 0.3
var buttons_in_place := false
@export var hover_area_x: int = 900
var base_button_x: int

var locked = false


@export var tutorial_active: bool = true
@export var tutorial_state: String = "house"

var tutorial_states: Array = ["house","farm"]
var has_killed: bool = false

var seconds
var old_day

var tutorial_text: Dictionary = {
	"objective":{
		"house":"1. Housing",
		"farm":"2. Farming",
		"fire":"3. Fire Fighting",
		"mark":"4. Finding Sinners",
		"kill":"5. Killing Sinners"
	},
	"directions":{
		"house":"Build 4 Houses",
		"farm":"Build 4 Farms",
		"fire":"Destroy 5 Fires\nwith Hand",
		"mark":"Sinner was spawned.\nUse marker tool\nto track.",
		"kill":"Once sinner has sinned,\nstreaking or murder\nkill them."
	}
}

func _ready() -> void:
	if tutorial_active:
		set_tutorial_state(tutorial_state)
	base_button_x=button_container.position.x
	button_container.position.x += button_offset
	faith_bar.max_value=game.faith_win
	seconds = game.day_timer;
	old_day = 0;
	handle_flash()
	
func handle_flash():
	var tween = create_tween()
	white_flash.modulate.a = 1.0
	tween.tween_property(white_flash, "modulate:a", 0, 2)
	tween.tween_callback(func(): white_flash.visible = false)

func _process(delta: float) -> void:
	update_display()
	update_stats()
	if tutorial_active:
		tutorial_process()
	check_hover_area()
	seconds = seconds + delta
	$Hand.rotation = -(fmod(seconds, 120.0) * TAU / 120.0) + deg_to_rad(-90)

func _on_pickup_button_pressed() -> void:
	ability_manager.signal_change("pickup")

func _on_destroy_button_pressed() -> void:
	ability_manager.signal_change("destroy")

func _on_house_button_pressed() -> void:
	ability_manager.signal_change("house")

func _on_farm_button_pressed() -> void:
	ability_manager.signal_change("farm")
	
func _on_marker_button_pressed() -> void:
	ability_manager.signal_change("marker")
	
	
func update_display():
	update_stats()
	

func update_stats():
	faith_bar.value = resource_manager.faith
	bread.text="Bread: %d"%resource_manager.bread
	population.text="Population: %d"%resource_manager.population
	if game.day<=7:
		day_counter.frame=game.day-1
	
func set_tutorial_state(state: String):
	if state=="over":
		tutorial_active=false
		tutorial_container.visible=false
		spawn_prophet()
		skip_tutorial.queue_free()
		_fade(true,tutorial_container)
		return
	if state=="mark":
		var person = character_scene.instantiate()
		get_tree().current_scene.add_child(person)
		person.sinner=true
		person.sin_timer=25
		person.global_position=prophet_spawn_location.global_position
		population_manager.register_character(person)
		person.change_name("Sinner")

	tutorial_state=state
	t_ob.text=tutorial_text["objective"][tutorial_state]
	t_dir.text=tutorial_text["directions"][tutorial_state]
	
func spawn_prophet():
	var prophet_spawner = prophet_spawner_scene.instantiate()
	game.add_child(prophet_spawner)
	prophet_spawner.global_position=prophet_spawn_location.global_position
	
func tutorial_process():
	match tutorial_state:
		"house":
			t_prog.text="%d/%d"%[t_data.houses,t_data.houses_needed]
			if t_data.houses>=t_data.houses_needed:
				set_tutorial_state("farm")
		"farm":
			t_prog.text="%d/%d"%[t_data.farms,t_data.farms_needed]
			if t_data.farms>=t_data.farms_needed:
				set_tutorial_state("fire")
		"fire":
			t_prog.text="%d/%d"%[t_data.fires,t_data.fires_needed]
			if t_data.fires>=t_data.fires_needed:
				set_tutorial_state("mark")
		"mark":
			t_prog.text=""
			if ability_manager.used_marker:
				set_tutorial_state("kill")
		"kill":
			if has_killed:
				set_tutorial_state("over")

func check_hover_area():
	var mouse_pos = game.get_global_mouse_position()
	var mouse_in_area = mouse_pos.x > hover_area_x
	if mouse_in_area and not buttons_in_place:
		show_buttons()
	elif not mouse_in_area and buttons_in_place:
		hide_buttons()

func show_buttons() -> void:
	if buttons_in_place:
		return
	buttons_in_place = true
	var tween = create_tween()
	tween.tween_property(button_container, "position:x", base_button_x, tween_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func hide_buttons() -> void:
	if not buttons_in_place:
		return
	buttons_in_place = false
	var tween = create_tween()
	tween.tween_property(button_container, "position:x", base_button_x+button_offset, tween_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func _fade(out: bool, object: Node):
	var target_alpha := 0.0 if out else 1.0
	var color = object.modulate
	color.a = target_alpha
	var tween = create_tween()
	tween.tween_property(object, "modulate", color, 0.3)

func _on_tutorial_hover_mouse_entered() -> void:
	if tutorial_active:
		_fade(true,tutorial_container)

func _on_tutorial_hover_mouse_exited() -> void:
	if tutorial_active:
		_fade(false,tutorial_container)


func _on_stats_hover_mouse_entered() -> void:
	_fade(true, $Timer)
	_fade(true,indicators)
	_fade(true, $Hand)


func _on_stats_hover_mouse_exited() -> void:
	_fade(false, $Timer)
	_fade(false,indicators)
	_fade(false, $Hand)


func _on_skip_tutorial_pressed() -> void:
	if tutorial_active:
		set_tutorial_state("over")
