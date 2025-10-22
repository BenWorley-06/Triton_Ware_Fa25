extends CanvasLayer
@onready var game = get_node("/root/Game")
@onready var day: Label = $MarginContainer/VBoxContainer/Day
@onready var faith: Label = $MarginContainer/VBoxContainer/Faith
@onready var bread: Label = $MarginContainer/VBoxContainer/Bread
@onready var sinner: Label = $MarginContainer/VBoxContainer/Sinner
@onready var texture_rect: TextureRect = $TextureRect
@onready var population_manager: PopulationManager = get_node("/root/Game/Managers/PopulationManager")

func _ready():
	
	await get_tree().create_timer(3).timeout
	start_day()
	
func start_day():
	var color = texture_rect.modulate
	color.a = 0
	var tween = create_tween()
	
	# Fade each element individually while preserving their original colors
	tween.tween_property(texture_rect, "modulate", color, 3)
	tween.parallel().tween_property(faith, "modulate", color, 3)
	tween.parallel().tween_property(bread, "modulate", color, 3)
	tween.parallel().tween_property(sinner, "modulate", color, 3)
	tween.parallel().tween_property(day, "modulate", color, 3)
	
	# This callback will wait for ALL parallel tweens to complete
	tween.tween_callback(func():
		visible = false
	)

func update_labels(bread_loss:int,faith_gain:int):
	day.text = "Day: %d" % game.day
	faith.text = "Faith: %d" % faith_gain
	bread.text = "Bread: %d" % bread_loss
	if population_manager.sinner_count>0:
		sinner.text="There is a sinner in your ranks..."
	else:
		sinner.text="Begins a peaceful day..."
