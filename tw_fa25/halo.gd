extends Area2D

@onready var aura: Sprite2D = $aura
@onready var halo: Sprite2D = $halo
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")
@export var pickup_scene: PackedScene

var people_in_area: int = 0
var praise_timer: float = 0
@export var time_for_faith: float = 10.0
var parent: Character
var base_scale: Vector2

func _ready() -> void:
	aura.z_index = -5
	halo.z_index = 12
	parent = get_parent()
	base_scale = halo.scale

	# ---- reusable glow shader ----
	var shader_code := """
	shader_type canvas_item;

	uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.6, 1.0);
	uniform float glow_strength = 0.5;
	uniform float glow_softness = 1.0;
	uniform float aura_alpha = 0.25; // global transparency control

	void fragment() {
		vec4 tex = texture(TEXTURE, UV);

		// Preserve base image color with transparency
		vec3 base_rgb = tex.rgb * tex.a;

		// Glow fades out with alpha falloff
		float glow = pow(tex.a, glow_softness);
		vec3 emit_rgb = glow_color.rgb * glow * glow_strength;

		// Subtle additive blend
		vec3 final_rgb = mix(base_rgb, base_rgb + emit_rgb, 0.3);

		// Final transparent output
		COLOR = vec4(final_rgb, tex.a * aura_alpha);
	}
	"""

	var shader := Shader.new()
	shader.code = shader_code

	# ---- halo glow (slightly stronger, still readable) ----
	var halo_mat := ShaderMaterial.new()
	halo_mat.shader = shader
	halo_mat.set_shader_parameter("glow_strength", 0.8)
	halo_mat.set_shader_parameter("glow_softness", 1.0)
	halo_mat.set_shader_parameter("glow_color", Color(1.0, 0.9, 0.6))
	halo_mat.set_shader_parameter("aura_alpha", 0.8)
	halo.material = halo_mat

	# ---- aura glow (very faint, transparent) ----
	var aura_mat := ShaderMaterial.new()
	aura_mat.shader = shader
	aura_mat.set_shader_parameter("glow_strength", 0.25)
	aura_mat.set_shader_parameter("glow_softness", 2.0)
	aura_mat.set_shader_parameter("glow_color", Color(0.9, 0.8, 0.7))
	aura_mat.set_shader_parameter("aura_alpha", 0.15) # <-- softer transparency
	aura.material = aura_mat

	# ---- gentle pulsing ----
	var tween := create_tween().set_loops()
	tween.tween_property(halo_mat, "shader_param/glow_strength", 1.0, 1.5)
	tween.tween_property(halo_mat, "shader_param/glow_strength", 0.6, 1.5)
	tween.tween_property(aura_mat, "shader_param/glow_strength", 0.3, 1.5)
	tween.tween_property(aura_mat, "shader_param/glow_strength", 0.15, 1.5)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)



func _process(delta: float) -> void:
	if people_in_area > 0 and not parent.selected:
		praise_timer += delta
		if praise_timer >= time_for_faith:
			var item = pickup_scene.instantiate()
			get_tree().current_scene.add_child(item)
			item.pickup_type="faith"
			item.global_position = global_position
			praise_timer = 0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		people_in_area += 1


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("character"):
		people_in_area -= 1
