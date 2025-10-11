extends StaticBody2D
class_name HouseScafold
var house_scene = preload("res://Scenes/Buildings/house.tscn")

var build_time:int = 3

func complete_building():
	var house = house_scene.instantiate()
	house.position = global_position
	get_parent().add_child(house)
	queue_free()  # remove scaffold
