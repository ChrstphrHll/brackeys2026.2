extends Node

signal resource_changed(resource_name: String, new_amount: int)


var _resources = {
	"wood": {
		"amount": 1000,
		"gatherable": 1,
		"difficulty": 1,
		"abundance": 1,
		"icon": preload("res://assets/WoodResource.png")
	},
	"scrap": {
		"amount": 111110,
		"gatherable": 1,
		"difficulty": 20,
		"abundance": 0.2,
		"icon": preload("res://assets/scrap.png")
	},
	"battery": {
		"amount": 0,
		"gatherable": -1,
		"difficulty": 20,
		"abundance": 0.2,
		"crafting_cost": {
			"wood": 10,
			"scrap": 10
		},
		"icon": preload("res://assets/scrap.png")
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
		push_warning("Tried to get unknown resource: " + resource)
		return 0

	return _resources[resource]["amount"]


func get_resource_names():
	return _resources.keys()


func get_gatherable_resources() -> Array[String]:
	var gatherable: Array[String] = []
	
	for resource in _resources:
		var info = _resources[resource]
		if info.has("gatherable") and info.gatherable > 0:
			gatherable.append(resource)
	return gatherable


func get_resource_icon(resource: String):
	if not _resources.has(resource):
		return null

	return _resources[resource].get("icon", null)


func get_resource_crafting_cost(resource: String):
	if not _resources.has(resource):
		return null
	
	var resource_info = _resources[resource]
	
	if not resource_info.has("crafting_cost"):
		return null
		
	return resource_info.crafting_cost


func get_resource_abundance(resource: String):
	return _resources[resource]["abundance"]


func get_resource_difficulty(resource: String):
	return _resources[resource]["difficulty"]


func can_afford(costs: Dictionary) -> bool:
	for resource_name in costs:
		var cost: int = costs[resource_name]
		if get_resource_amount(resource_name) < cost:
			return false
	return true


func spend_resources(costs: Dictionary) -> bool:
	if not can_afford(costs):
		return false
	for resource_name in costs:
		var cost: int = costs[resource_name]
		modify_resource(resource_name, -cost)
	return true
