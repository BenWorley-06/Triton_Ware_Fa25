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

func _process(delta: float) -> void:
	update_display()

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
