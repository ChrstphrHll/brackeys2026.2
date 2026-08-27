extends Node

signal resource_changed(resource_name: String, new_amount: int)


var _resources = {
	"wood": {
		"amount": 0,
		"difficulty": 1,
		"abundance": 1,
		"icon": preload("res://assets/WoodResource.png")
	},
	"scrap": {
		"amount": 0,
		"difficulty": 2,
		"abundance": 0.2
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


func get_resource_icon(resource: String):
	if not _resources.has(resource):
		return null

	return _resources[resource].get("icon", null)


func get_resource_abundance(resource: String):
	return _resources[resource]["abundance"]


func get_resource_difficulty(resource: String):
	return _resources[resource]["difficulty"]
