extends CanvasLayer
@onready var ability_manager = get_node("/root/Game/Managers/AbilityManager")
@onready var pickup_button: Button = $MarginContainer/VBoxContainer/PickupButton
@onready var destroy_button: Button = $MarginContainer/VBoxContainer/DestroyButton
@onready var house_button: Button = $MarginContainer/VBoxContainer/HouseButton
@onready var farm_button: Button = $MarginContainer/VBoxContainer/FarmButton


func _on_pickup_button_pressed() -> void:
	ability_manager.signal_change("pickup")

func _on_destroy_button_pressed() -> void:
	ability_manager.signal_change("destroy")

func _on_house_button_pressed() -> void:
	ability_manager.signal_change("house")

func _on_farm_button_pressed() -> void:
	ability_manager.signal_change("farm")
