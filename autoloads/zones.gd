extends Node


signal zone_changed(new_zone: int)


const machine_scene = \
	preload("res://machines/machine.tscn")


const MACHINE_NAMES: Array[String] = [
	"MULE",
	"SCRAPPER",
	"CLANK",
	"RUSTY",
	"BUCKET",
	"GRINDER",
	"PATCH",
	"RATTLE",
	"DOZER",
	"JUNKER"
]


# 0 = Wasteland
# 1 = Swamp
# 2 = Ravine
# 3 = City

var current_zone: int = 0


var transitions: Array[Dictionary] = [
	{
		"name": "Swamp",
		"cost": {
			"wood": 100,
			"rocks": 60,
			"scrap": 40,
			"steel": 3
		}
	},

	{
		"name": "Ravine",
		"cost": {
			"wood": 450,
			"rocks": 260,
			"scrap": 180,
			"crystallized_gunpowder": 35,
			"steel": 10,
			"battery": 4
		}
	},

	{
		"name": "City",
		"cost": {
			"wood": 1800,
			"rocks": 1000,
			"scrap": 800,
			"crystallized_gunpowder": 150,
			"ether": 100,
			"computer_cubes": 50,
			"steel": 30,
			"battery": 15
		}
	}
]


func get_zone_name(zone: int) -> String:
	match zone:
		0:
			return "Wasteland"
		1:
			return "Swamp"
		2:
			return "Ravine"
		3:
			return "City"

	return "Unknown"


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

	return index == current_zone


func unlock_transition(index: int) -> bool:
	if not is_transition_available(index):
		return false

	var cost := get_transition_cost(index)

	if not Resources.spend_resources(cost):
		return false

	current_zone += 1

	zone_changed.emit(current_zone)

	return true


# ZONE PRODUCTION BONUS
# --------------------------------------------

func get_gather_multiplier() -> float:
	match current_zone:
		0:
			return 1.0

		1:
			return 1.30

		2:
			return 1.80

		3:
			return 2.50

	return 1.0


# SCAVENGING
# --------------------------------------------

func roll_scavenge() -> Dictionary:
	# Machine chance is controlled by the tech tree.
	if randf() < TechTree.scavenge_machine_chance:
		return {
			"type": "machine",
			"message": "MACHINE SIGNAL DETECTED!"
		}

	var loot_table: Array[Dictionary] = [
		{
			"type": "nothing",
			"weight": 18.0
		},
		{
			"type": "resource",
			"resource": "scrap",
			"weight": 32.0,
			"min": 1,
			"max": 3
		},
		{
			"type": "resource",
			"resource": "nuts_and_bolts",
			"weight": 22.0,
			"min": 1,
			"max": 2
		},
		{
			"type": "resource",
			"resource": "rocks",
			"weight": 16.0,
			"min": 2,
			"max": 4
		},
		{
			"type": "resource",
			"resource": "wood",
			"weight": 12.0,
			"min": 2,
			"max": 5
		}
	]

	if current_zone >= 1:
		loot_table.append({
			"type": "resource",
			"resource": "crystallized_gunpowder",
			"weight": 15.0,
			"min": 1,
			"max": 2
		})

	if current_zone >= 2:
		loot_table.append({
			"type": "resource",
			"resource": "ether",
			"weight": 10.0,
			"min": 1,
			"max": 2
		})

		loot_table.append({
			"type": "resource",
			"resource": "computer_cubes",
			"weight": 6.0,
			"min": 1,
			"max": 1
		})

	var selected := \
		_pick_weighted_result(loot_table)

	if selected["type"] == "nothing":
		return {
			"type": "nothing",
			"message": "Nothing but rust."
		}

	var amount: int = randi_range(
		selected["min"],
		selected["max"]
	)

	return {
		"type": "resource",
		"resource": selected["resource"],
		"amount": amount,

		"message": "FOUND: %d %s" % [
			amount,
			Resources.get_resource_display_name(
				selected["resource"]
			).to_upper()
		]
	}


func _pick_weighted_result(
	table: Array[Dictionary]
) -> Dictionary:

	var total_weight := 0.0

	for entry in table:
		total_weight += float(entry["weight"])

	var roll := randf() * total_weight

	for entry in table:
		roll -= float(entry["weight"])

		if roll <= 0:
			return entry

	return table.back()


func create_scavenged_machine() -> Machine:
	var instance: Machine = \
		machine_scene.instantiate()

	instance.machine_name = "%s-%02d" % [
		MACHINE_NAMES.pick_random(),
		randi_range(1, 99)
	]

	# Useful compared with the player,
	# but still pretty bad initially.
	instance.base_speed = 0.90
	instance.base_efficiency = 1.0
	instance.is_player = false

	return instance
