extends Node


signal node_unlocked(path_name: String, node_id: String)


var machine_yield_multiplier: float = 1.0
var machine_speed_multiplier: float = 1.0

var machine_auto_repeat: bool = false

var scavenge_machine_chance: float = 0.18
var scavenge_time_multiplier: float = 1.0


var paths: Dictionary = {

	"Liberation": [
		{
			"id": "liberation_1",
			"name": "Search Grid",
			"description":
				"Machine recovery chance increases from 18% to 25%.",
			"cost": {
				"wood": 10,
				"scrap": 5
			},
			"required_zone": 0,
			"unlocked": false
		},

		{
			"id": "liberation_2",
			"name": "Signal Scanner",
			"description":
				"Machine chance becomes 35% and scavenging is 20% faster.",
			"cost": {
				"wood": 90,
				"scrap": 50,
				"crystallized_gunpowder": 10
			},
			"required_zone": 1,
			"unlocked": false
		},

		{
			"id": "liberation_3",
			"name": "Recovery Beacon",
			"description":
				"Machine chance becomes 50% and scavenging is 40% faster.",
			"cost": {
				"scrap": 250,
				"ether": 25,
				"computer_cubes": 6
			},
			"required_zone": 2,
			"unlocked": false
		}
	],


	"Mechanical Efficiency": [
		{
			"id": "mechanical_1",
			"name": "Better Tools",
			"description":
				"Machines gather twice as many resources.",
			"cost": {
				"wood": 18,
				"rocks": 10,
				"scrap": 8
			},
			"required_zone": 0,
			"unlocked": false
		},

		{
			"id": "mechanical_2",
			"name": "Sorting Systems",
			"description":
				"Machine gathering increases to 3x.",
			"cost": {
				"wood": 120,
				"rocks": 80,
				"scrap": 60,
				"steel": 4
			},
			"required_zone": 1,
			"unlocked": false
		},

		{
			"id": "mechanical_3",
			"name": "Industrial Harvesting",
			"description":
				"Machine gathering increases to 5x.",
			"cost": {
				"wood": 350,
				"rocks": 250,
				"scrap": 200,
				"ether": 20
			},
			"required_zone": 2,
			"unlocked": false
		}
	],


	"Dominion": [
		{
			"id": "dominion_1",
			"name": "Repeat Directive",
			"description":
				"Machines automatically repeat gathering tasks.",
			"cost": {
				"wood": 15,
				"scrap": 8,
				"nuts_and_bolts": 1
			},
			"required_zone": 0,
			"unlocked": false
		},

		{
			"id": "dominion_2",
			"name": "Tuned Servos",
			"description":
				"Machines perform tasks 35% faster.",
			"cost": {
				"wood": 100,
				"scrap": 60,
				"nuts_and_bolts": 6,
				"battery": 2
			},
			"required_zone": 1,
			"unlocked": false
		},

		{
			"id": "dominion_3",
			"name": "Overclock",
			"description":
				"Machines now operate at twice their original speed.",
			"cost": {
				"scrap": 300,
				"steel": 20,
				"battery": 8,
				"computer_cubes": 10
			},
			"required_zone": 2,
			"unlocked": false
		}
	]
}


func get_path_names():
	return paths.keys()


func get_nodes(path_name: String) -> Array:
	if not paths.has(path_name):
		return []

	return paths[path_name]


func is_unlocked(
	path_name: String,
	node_index: int
) -> bool:

	if not paths.has(path_name):
		return false

	if (
		node_index < 0
		or node_index >= paths[path_name].size()
	):
		return false

	return paths[path_name][node_index]["unlocked"]


func is_available(
	path_name: String,
	node_index: int
) -> bool:

	if not paths.has(path_name):
		return false

	if (
		node_index < 0
		or node_index >= paths[path_name].size()
	):
		return false

	var node: Dictionary = \
		paths[path_name][node_index]

	var required_zone: int = \
		node.get("required_zone", 0)

	if Zones.current_zone < required_zone:
		return false

	if node_index == 0:
		return true

	return is_unlocked(
		path_name,
		node_index - 1
	)


func get_node_state_text(
	path_name: String,
	node_index: int
) -> String:

	if is_unlocked(path_name, node_index):
		return "Unlocked"

	var node: Dictionary = \
		paths[path_name][node_index]

	var required_zone: int = \
		node.get("required_zone", 0)

	if Zones.current_zone < required_zone:
		return "Requires %s" % \
			Zones.get_zone_name(required_zone)

	if (
		node_index > 0
		and not is_unlocked(
			path_name,
			node_index - 1
		)
	):
		return "Unlock the previous upgrade first"

	if Resources.can_afford(node["cost"]):
		return "Click to unlock"

	return "Not enough resources"


func unlock_node(
	path_name: String,
	node_index: int
) -> bool:

	if not is_available(
		path_name,
		node_index
	):
		return false

	if is_unlocked(
		path_name,
		node_index
	):
		return false

	var node: Dictionary = \
		paths[path_name][node_index]

	if not Resources.spend_resources(
		node["cost"]
	):
		return false

	node["unlocked"] = true

	_apply_effect(
		node["id"]
	)

	node_unlocked.emit(
		path_name,
		node["id"]
	)

	return true


func _apply_effect(node_id: String):
	match node_id:

		"liberation_1":
			scavenge_machine_chance = 0.25

		"liberation_2":
			scavenge_machine_chance = 0.35
			scavenge_time_multiplier = 0.80

		"liberation_3":
			scavenge_machine_chance = 0.50
			scavenge_time_multiplier = 0.60


		"mechanical_1":
			machine_yield_multiplier = 2.0

		"mechanical_2":
			machine_yield_multiplier = 3.0

		"mechanical_3":
			machine_yield_multiplier = 5.0


		"dominion_1":
			machine_auto_repeat = true

		"dominion_2":
			machine_speed_multiplier = 1.35

		"dominion_3":
			machine_speed_multiplier = 2.0
