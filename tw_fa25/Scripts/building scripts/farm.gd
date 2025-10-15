extends StaticBody2D
class_name Farm

@onready var sprite: AnimatedSprite2D = $sprite
@export var pickup_scene: PackedScene

var max_state: int = 4
var growth_state: int = 0
@export var state_change_time: float = 5

var change_timer: float = 0

var harvest_amount: int = 2

var growing: bool = true
var harvestable:bool = false

var type="farm"

func _ready() -> void:
	z_index=-1

func _process(delta: float) -> void:
	if growing:
		change_timer += delta
		if change_timer >= state_change_time:
			change_timer = 0
			growth_state = clamp(growth_state + 1, 0, max_state)
			if growth_state == max_state:
				request_harvest()
	sprite.frame = growth_state

func request_harvest():
	growing = false
	harvestable=true
	var job = Farm_Job.new()
	job.farm = self
	get_node("/root/Game/Managers/PopulationManager").add_job(job)

func harvest():
	harvestable=false
	growth_state=0
	growing=true
	get_node("/root/Game/Managers/ResourceManager").add_bread(harvest_amount)
	for i in range(harvest_amount):
		var item = pickup_scene.instantiate()
		get_tree().current_scene.add_child(item)
		item.pickup_type="bread"
		item.global_position = global_position
	
	
