extends Node2D

@export var lifetime: float = 1.0
@onready var particles: GPUParticles2D = $Particles

func _ready() -> void:
	z_index = 10
	print("bam")
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()
