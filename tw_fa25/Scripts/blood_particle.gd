extends Node2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	z_index = 10
	cpu_particles_2d.one_shot = true
	cpu_particles_2d.emitting = true 

	await get_tree().create_timer(cpu_particles_2d.lifetime + 0.1).timeout
	queue_free()
