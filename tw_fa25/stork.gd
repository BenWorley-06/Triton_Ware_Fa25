extends Node2D

@export var speed = 10
@export var min_spawn_x: int = 600
@export var max_spawn_x: int = 1000
@export var character_scene: PackedScene
@export var halo_scene: PackedScene
@onready var people_manager = get_node("/root/Game/Managers/PopulationManager")
@onready var gui: CanvasLayer = get_node("/root/Game/GUI")
@onready var sprite: AnimatedSprite2D = $sprite
@onready var shadow: Sprite2D = $shadow

var spawn_x: int = 0
var spawned: bool=false

var start_pos_sprite: float

func _ready() -> void:
	spawn_x=randi_range(min_spawn_x,max_spawn_x)
	z_index=100
	sprite.play("flying-bag")
	start_pos_sprite = sprite.position.y
	
func _process(delta: float) -> void:
	global_position.x-=speed*delta
	if global_position.x<=spawn_x and not spawned:
		drop_animation()
		spawned=true
	elif global_position.x<-600:
		queue_free()
		
func drop_animation():
	sprite.play("coming down")
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", shadow.position.y-40, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_down_finished"))
	
func _on_down_finished() -> void:
	drop_baby()
	sprite.play("going up")
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", start_pos_sprite, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_swoop_finished"))
	
func _on_swoop_finished():
	sprite.play("flying-no_bag")

func drop_baby():
	var baby = character_scene.instantiate()
	
	if randf()<0.25:
		baby.sinner=true
	if not baby.prophet and false:
		var sinner_needed = people_manager.should_be_sinner()
		if sinner_needed==1:
			if randf()<0.25:
				baby.sinner=true
		if sinner_needed==2:
			baby.sinner=false
	if gui.tutorial_active:
		baby.sinner=false
	get_tree().current_scene.add_child(baby)
	baby.global_position=global_position
	
