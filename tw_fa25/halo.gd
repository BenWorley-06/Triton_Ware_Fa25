extends Area2D

@onready var aura: Sprite2D = $aura
@onready var halo: Sprite2D = $halo
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")

var people_in_area: int = 0
var praise_timer: float = 0
@export var time_for_faith: float = 10.0
var parent: Character
var base_scale: Vector2

func _ready() -> void:
	aura.z_index = 0
	halo.z_index = 12
	var mat := CanvasItemMaterial.new()
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.6) # warm golden glow
	mat.emission_energy = 1.5           # adjust intensity
	halo.material = mat
	parent = get_parent()
	base_scale = halo.scale

	# Tween pulse around base scale, not absolute
	var tween = create_tween().set_loops()
	tween.tween_property(halo, "scale", base_scale * 1.4, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(halo, "scale", base_scale, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if people_in_area > 0 and not parent.selected:
		praise_timer += delta
		if praise_timer >= time_for_faith:
			resource_manager.add_faith(1)
			praise_timer = 0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		people_in_area += 1

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("character"):
		people_in_area -= 1
