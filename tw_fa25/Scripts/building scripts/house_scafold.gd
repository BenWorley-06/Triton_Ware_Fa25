extends StaticBody2D
class_name HouseScafold
var house_scene = preload("res://Scenes/Buildings/house.tscn")

var build_time:int = 3

func complete_building():
	var house = house_scene.instantiate()
	house.position = global_position
	get_parent().add_child(house)
	get_node("/root/Game/Managers/BuildingManager").register_house(house)
	get_node("/root/Game/Managers/BuildingManager").house_scafolds.erase(self)
	queue_free()  # remove scaffold
