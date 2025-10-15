extends Label
class_name ErrorText

@export var lifetime: float = 3
@export var fadetime: float = 1

var timer: float = 0

var messages: Dictionary = {"loc":"Invalid Location!",
					"house":"Build More Houses First!",
					"peeps":"Not Enough People!"}
					
var tween: Tween
func _ready():
	# Red glow setup
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
	self_modulate = Color(1, 0.2, 0.2, 1)  # red tint

	# Tween setup for grow/shrink
	tween = create_tween()
	tween.set_loops()  # infinite looping pulse
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func set_message(id: String):
	text=messages[id]

func _process(delta: float) -> void:
	timer+=delta
	if timer>=lifetime:
		queue_free()
	if timer > lifetime - fadetime:
		var remaining = lifetime - timer
		modulate.a = clamp(remaining / fadetime, 0.0, 1.0)
