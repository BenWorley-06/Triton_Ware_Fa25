extends Area2D
@onready var shadow: Sprite2D = $shadow
@onready var hand: Sprite2D = $hand
@onready var audio: AudioStreamPlayer2D = $audio

@export var hand_down_duration: float = 0.4
@export var hand_up_duration: float = 0.4
@export var pause_time: float = 0.2

var hand_start_pos: Vector2

func _ready():
	hand_start_pos = hand.position
	hand.z_index=50

func smite_buildings():
	var tween = create_tween()
	var down_pos = shadow.position +Vector2(0,-15)

	tween.tween_property(hand, "position", down_pos, hand_down_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(Callable(self, "_destroy_buildings"))

	tween.tween_interval(pause_time)

	tween.tween_property(hand, "position", hand_start_pos, hand_up_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _destroy_buildings():
	var overlapping_bodies = get_overlapping_bodies()
	audio.play()
	for body in overlapping_bodies:
		if body.is_in_group("building"):
			get_node("/root/Game/Managers/BuildingManager").destroy_building(body)
		elif body.is_in_group("character"):
			body.smashed()
