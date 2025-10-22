extends CanvasLayer
@onready var button: Button = $TextureRect/MarginContainer/VBoxContainer/Button
@onready var game = get_node("/root/Game")
@onready var day: Label = $TextureRect/MarginContainer/VBoxContainer/Day
@onready var faith: Label = $TextureRect/MarginContainer/VBoxContainer/Faith
@onready var bread: Label = $TextureRect/MarginContainer/VBoxContainer/Bread
@onready var sinner: Label = $TextureRect/MarginContainer/VBoxContainer/Sinner
@onready var texture_rect: TextureRect = $TextureRect
@onready var population_manager: PopulationManager = get_node("/root/Game/Managers/PopulationManager")

func _on_button_pressed() -> void:
	print('pressed')
	game.end_day()
	
func end_day(bread_loss:int,faith_gain:int):
	update_labels(bread_loss,faith_gain)
	visible=true
	
	# Set initial alpha to 0 for all elements
	var elements = [texture_rect, faith, bread, sinner, day, button]
	for element in elements:
		var color = element.modulate
		color.a = 0
		element.modulate = color
	
	# Create tween to fade in all elements simultaneously
	var target_color = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate", target_color, 0.3)
	tween.parallel().tween_property(faith, "modulate", target_color, 0.3)
	tween.parallel().tween_property(bread, "modulate", target_color, 0.3)
	tween.parallel().tween_property(sinner, "modulate", target_color, 0.3)
	tween.parallel().tween_property(day, "modulate", target_color, 0.3)
	tween.parallel().tween_property(button, "modulate", target_color, 0.3)

func update_labels(bread_loss:int,faith_gain:int):
	day.text = "Day: %d" % game.day
	faith.text = "Faith: +%d" % faith_gain
	bread.text = "Bread: %d" % bread_loss
	if population_manager.sinner_count>0:
		sinner.text="There is a sinner in your ranks..."
	else:
		sinner.text=""
