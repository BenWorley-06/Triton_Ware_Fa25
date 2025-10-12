extends Area2D
@onready var aura: Sprite2D = $aura
@onready var halo: Sprite2D = $halo
@onready var resource_manager: ResourceManager = get_node("/root/Game/Managers/ResourceManager")

var people_in_area: int = 0
var praise_timer: float = 0
@export var time_for_faith = 10
var parent: Character

func _ready() -> void:
	aura.z_index=0
	halo.z_index=12
	parent=get_parent()

func _process(delta: float) -> void:
	if people_in_area>0 and parent.selected==false:
		praise_timer+=delta
		if praise_timer>=time_for_faith:
			resource_manager.add_faith(1)
			praise_timer=0
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		people_in_area+=1

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("character"):
		people_in_area-=1
