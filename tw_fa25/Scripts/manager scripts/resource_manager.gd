extends Node
class_name ResourceManager

<<<<<<< Updated upstream
@export var faith: int = 50
@export var bread: int = 10
@export var population: int = 4 #Change later
=======
@export var faith: float = 50
@export var bread: int = 4
@export var population: int = 0
>>>>>>> Stashed changes

func add_faith(amount: int):
	faith += amount

func consume_faith(amount: int) -> bool:
	if faith >= amount:
		faith -= amount
		return true
	return false

func add_bread(amount: int):
	bread += amount

func consume_bread(amount: int) -> bool:
	if bread >= amount:
		bread -= amount
		return true
	return false

func add_population(amount: int):
	population += amount

func remove_population(amount: int):
	population = max(0, population - amount)
