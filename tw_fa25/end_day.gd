extends CanvasLayer
@onready var button: TextureButton = $TextureRect/MarginContainer/VBoxContainer/Button
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
	var color = texture_rect.modulate
	texture_rect.modulate.a=0
	color.a=1
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate", color, 0.3)
	
func start_day():
	var color = texture_rect.modulate
	color.a=0
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate", color, 0.3)
	tween.tween_callback(func():
		visible = false
	)
	texture_rect.modulate.a=1

func update_labels(bread_loss:int,faith_gain:int):
	day.text = "Day: %d" % (game.day)
	faith.text = "Faith: +%d" % faith_gain
	bread.text = "Bread: %d" % bread_loss
	if population_manager.sinner_count>0:
		sinner.text="There is a sinner in your ranks..."
	else:
		sinner.text=""
