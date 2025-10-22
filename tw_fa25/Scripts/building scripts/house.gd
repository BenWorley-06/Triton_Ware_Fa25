extends StaticBody2D

class_name House
var type="house"
@onready var sprite: AnimatedSprite2D = $sprite

var color: String
var colors: Array = ["red","blue","green"]

var default_animation: String

func _ready() -> void:
	color = colors.pick_random()
	default_animation = color+"-static"
	sprite.play(default_animation)
