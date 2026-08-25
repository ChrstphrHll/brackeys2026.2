extends Node

var _resources = {
	"wood": {
		"amount": 0,
		"difficulty": 1,
		"abundance": 1
	}
}


func modify_resource(resource: String, delta: int):
	var current_amount = _resources.get(resource).amount
	_resources[resource].amount = current_amount + delta
	print(_resources[resource].amount)


func get_resource_abundance(resource):
	return _resources[resource].abundance


func get_resource_difficulty(resource):
	return _resources[resource].difficulty
