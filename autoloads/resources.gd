extends Node

signal resource_changed(resource_name: String, new_amount: int)


var _resources: Dictionary = {
	"wood": {
		"display_name": "Wood",
		"amount": 0,
		"gatherable": true,
		"unlock_zone": 0,
		"difficulty": 4.0,
		"base_yield": 1,
		"icon": preload("res://assets/WoodResource.png")
	},

	"rocks": {
		"display_name": "Rocks",
		"amount": 0,
		"gatherable": true,
		"unlock_zone": 0,
		"difficulty": 5.0,
		"base_yield": 1,
		"icon": preload("res://assets/Rocks.png")
	},

	"scrap": {
		"display_name": "Scrap",
		"amount": 0,
		"gatherable": true,
		"unlock_zone": 0,
		"difficulty": 8.0,
		"base_yield": 1,
		"icon": preload("res://assets/scrap.png")
	},

	"nuts_and_bolts": {
		"display_name": "Nuts & Bolts",
		"amount": 0,
		"gatherable": false,
		"unlock_zone": 0,
		"difficulty": 1.0,
		"base_yield": 1,
		"icon": preload("res://assets/Nutsandbolts.png")
	},

	"steel": {
		"display_name": "Steel",
		"amount": 0,
		"gatherable": false,
		"unlock_zone": 0,
		"difficulty": 12.0,
		"crafting_cost": {
			"scrap": 5,
			"rocks": 4
		},
		"icon": preload("res://assets/Rubber.png")
	},

	"battery": {
		"display_name": "Battery",
		"amount": 0,
		"gatherable": false,
		"unlock_zone": 0,
		"difficulty": 16.0,
		"crafting_cost": {
			"steel": 2,
			"nuts_and_bolts": 2,
			"scrap": 2
		},
		"icon": preload("res://assets/Battery.png")
	},

	"crystallized_gunpowder": {
		"display_name": "Crystallized Gunpowder",
		"amount": 0,
		"gatherable": true,
		"unlock_zone": 1,
		"difficulty": 10.0,
		"base_yield": 1,
		"icon": preload("res://assets/CrystalizedGunpowder.png")
	},

	"ether": {
		"display_name": "Ether",
		"amount": 0,
		"gatherable": true,
		"unlock_zone": 2,
		"difficulty": 14.0,
		"base_yield": 1,
		"icon": preload("res://assets/Ether.png")
	},

	"computer_cubes": {
		"display_name": "Computer Cubes",
		"amount": 0,
		"gatherable": true,
		"unlock_zone": 2,
		"difficulty": 18.0,
		"base_yield": 1,
		"icon": preload("res://assets/ComputerCube.png")
	}
}


func modify_resource(resource: String, delta: int):
	if not _resources.has(resource):
		push_warning("Tried to modify unknown resource: " + resource)
		return

	_resources[resource]["amount"] += delta

	resource_changed.emit(
		resource,
		_resources[resource]["amount"]
	)


func get_resource_amount(resource: String) -> int:
	if not _resources.has(resource):
		return 0

	return _resources[resource]["amount"]


func get_resource_names():
	return _resources.keys()


func get_resource_display_name(resource: String) -> String:
	if not _resources.has(resource):
		return resource.capitalize()

	return _resources[resource].get(
		"display_name",
		resource.capitalize()
	)


func get_gatherable_resources() -> Array[String]:
	var gatherable: Array[String] = []

	for resource_name in _resources:
		var info: Dictionary = _resources[resource_name]

		if (
			info.get("gatherable", false)
			and info.get("unlock_zone", 0) <= Zones.current_zone
		):
			gatherable.append(resource_name)

	return gatherable


func get_visible_resource_names() -> Array[String]:
	var visible_resources: Array[String] = []

	for resource_name in _resources:
		var info: Dictionary = _resources[resource_name]

		if info.get("unlock_zone", 0) <= Zones.current_zone:
			visible_resources.append(resource_name)

	return visible_resources


func get_craftable_resources() -> Array[String]:
	var craftable: Array[String] = []

	for resource_name in _resources:
		var info: Dictionary = _resources[resource_name]

		if (
			info.has("crafting_cost")
			and info.get("unlock_zone", 0) <= Zones.current_zone
		):
			craftable.append(resource_name)

	return craftable


func get_resource_icon(resource: String):
	if not _resources.has(resource):
		return null

	return _resources[resource].get("icon", null)


func get_resource_crafting_cost(resource: String):
	if not _resources.has(resource):
		return null

	return _resources[resource].get("crafting_cost", null)


func get_resource_difficulty(resource: String) -> float:
	if not _resources.has(resource):
		return 1.0

	return float(_resources[resource].get("difficulty", 1.0))


func get_resource_base_yield(resource: String) -> int:
	if not _resources.has(resource):
		return 1

	return int(_resources[resource].get("base_yield", 1))


func can_afford(costs: Dictionary) -> bool:
	for resource_name in costs:
		if get_resource_amount(resource_name) < int(costs[resource_name]):
			return false

	return true


func spend_resources(costs: Dictionary) -> bool:
	if not can_afford(costs):
		return false

	for resource_name in costs:
		modify_resource(
			resource_name,
			-int(costs[resource_name])
		)

	return true
