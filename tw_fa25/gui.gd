extends CanvasLayer
@onready var game = get_node("/root/Game")
@onready var ability_manager = get_node("/root/Game/Managers/AbilityManager")
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")

@onready var pickup_button: Button = $MarginContainer/VBoxContainer/PickupButton
@onready var destroy_button: Button = $MarginContainer/VBoxContainer/DestroyButton
@onready var house_button: Button = $MarginContainer/VBoxContainer/HouseButton
@onready var farm_button: Button = $MarginContainer/VBoxContainer/FarmButton

@onready var faith_bar: ProgressBar = $Indicators/HBoxContainer/VBoxContainer/faith_bar
@onready var bread: Label = $Indicators/HBoxContainer/VBoxContainer/HBoxContainer/Bread
@onready var population: Label = $Indicators/HBoxContainer/VBoxContainer/HBoxContainer/Population
@onready var time_label: Label = $Indicators/HBoxContainer/time_label

@export var t_data: TutorialData
@onready var tutorial_container: MarginContainer = $tutorial_container
@onready var t_ob: Label = $tutorial_container/VBoxContainer/t_ob
@onready var t_dir: Label = $tutorial_container/VBoxContainer/t_dir
@onready var t_prog: Label = $tutorial_container/VBoxContainer/t_prog

@export var tutorial_active: bool = true
@export var tutorial_state: String = "house"

var tutorial_states: Array = ["house","farm"]

var tutorial_text: Dictionary = {
	"objective":{
		"house":"1. Housing",
		"farm":"2. Farming",
		"fire":"3. Fire Fighting"
	},
	"directions":{
		"house":"Build 4 Houses",
		"farm":"Build 4 Farms",
		"fire":"Destroy 5 Fires\nwith Hand"
	}
}
func _ready() -> void:
	if tutorial_active:
		set_tutorial_state(tutorial_state)

func _process(delta: float) -> void:
	update_display()
	if tutorial_active:
		tutorial_process()

func _on_pickup_button_pressed() -> void:
	ability_manager.signal_change("pickup")

func _on_destroy_button_pressed() -> void:
	ability_manager.signal_change("destroy")

func _on_house_button_pressed() -> void:
	ability_manager.signal_change("house")

func _on_farm_button_pressed() -> void:
	ability_manager.signal_change("farm")
	
	
func update_display():
	update_stats()
	

func update_stats():
	faith_bar.value = resource_manager.faith
	bread.text="Bread: %d"%resource_manager.bread
	population.text="Population: %d"%resource_manager.population
	time_label.text="Time:\n%d"%game.day_timer
	
func set_tutorial_state(state: String):
	if state=="over":
		tutorial_active=false
		tutorial_container.visible=false
		return
	tutorial_state=state
	t_ob.text=tutorial_text["objective"][tutorial_state]
	t_dir.text=tutorial_text["directions"][tutorial_state]
	
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
				set_tutorial_state("over")
