extends Node


signal zone_changed(new_zone: int)


const machine_scene = preload("res://machines/machine.tscn")


# 0 = starting wasteland area
# 1 = swamp unlocked
# 2 = machine ravine unlocked
# 3 = city unlocked
var current_zone: int = 0


# placeholder costs
# Change to balance
var transitions: Array[Dictionary] = [
	{
		"name": "Swamp",
		"cost": {
			"wood": 10
		}
	},
	{
		"name": "Ravine",
		"cost": {
			"wood": 25,
			"scrap": 2
		}
	},
	{
		"name": "City",
		"cost": {
			"wood": 50,
			"scrap": 5
		}
	}
]


func get_transition_name(index: int) -> String:
	if index < 0 or index >= transitions.size():
		return "Unknown"

	return transitions[index]["name"]


func get_transition_cost(index: int) -> Dictionary:
	if index < 0 or index >= transitions.size():
		return {}

	return transitions[index]["cost"]


func is_transition_unlocked(index: int) -> bool:
	return index < current_zone


func is_transition_available(index: int) -> bool:
	if index < 0 or index >= transitions.size():
		return false

	# Only the transition immediately in front of
	# the player can currently be bought.
	return index == current_zone


func unlock_transition(index: int) -> bool:
	if not is_transition_available(index):
		return false

	var cost: Dictionary = get_transition_cost(index)

	if not Resources.spend_resources(cost):
		return false

	current_zone += 1

	zone_changed.emit(current_zone)

	return true


func get_scavenge_result(efficiency) -> Machine:
	var instance = machine_scene.instantiate()
	instance.machine_name = "new guy!!"

	return instance
