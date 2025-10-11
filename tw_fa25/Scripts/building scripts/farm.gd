extends StaticBody2D
class_name Farm
@onready var sprite: AnimatedSprite2D = $sprite
var max_state: int = 4
var growth_state: int = 0
var state_change_time: float = 5
var change_timer: float = 0

var harvest_amount: int = 2

var growing: bool = true
var harvestable:bool = false

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
	
