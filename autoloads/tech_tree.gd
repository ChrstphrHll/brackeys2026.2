extends Node

signal node_unlocked(path_name: String, node_id: String)


var paths: Dictionary = {
	"Liberation": [
		{
			"id": "liberation_1",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 10},
			"unlocked": false
		},
		{
			"id": "liberation_2",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 20},
			"unlocked": false
		},
		{
			"id": "liberation_3",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 30, "scrap": 2},
			"unlocked": false
		},
		{
			"id": "liberation_4",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 50, "scrap": 5},
			"unlocked": false
		}
	],

	"Mechanical Efficiency": [
		{
			"id": "mechanical_1",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 10},
			"unlocked": false
		},
		{
			"id": "mechanical_2",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 20},
			"unlocked": false
		},
		{
			"id": "mechanical_3",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 30, "scrap": 2},
			"unlocked": false
		},
		{
			"id": "mechanical_4",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 50, "scrap": 5},
			"unlocked": false
		}
	],

	"Spirit Strength": [
		{
			"id": "spirit_1",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 10},
			"unlocked": false
		},
		{
			"id": "spirit_2",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 20},
			"unlocked": false
		},
		{
			"id": "spirit_3",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 30, "scrap": 2},
			"unlocked": false
		},
		{
			"id": "spirit_4",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 50, "scrap": 5},
			"unlocked": false
		}
	],

	"Dominion": [
		{
			"id": "dominion_1",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 10},
			"unlocked": false
		},
		{
			"id": "dominion_2",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 20},
			"unlocked": false
		},
		{
			"id": "dominion_3",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 30, "scrap": 2},
			"unlocked": false
		},
		{
			"id": "dominion_4",
			"name": "Test",
			"description": "This is a test",
			"cost": {"wood": 50, "scrap": 5},
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


func is_unlocked(path_name: String, node_index: int) -> bool:
	if not paths.has(path_name):
		return false

	if node_index < 0 or node_index >= paths[path_name].size():
		return false

	return paths[path_name][node_index]["unlocked"]


func is_available(path_name: String, node_index: int) -> bool:
	if not paths.has(path_name):
		return false

	if node_index < 0 or node_index >= paths[path_name].size():
		return false

	# The first node of every path is immediately available.
	if node_index == 0:
		return true

	# All later nodes depend only on the previous node
	# within their own path. Could make more complex tree structure later
	return is_unlocked(path_name, node_index - 1)


func unlock_node(path_name: String, node_index: int) -> bool:
	if not paths.has(path_name):
		return false

	if node_index < 0 or node_index >= paths[path_name].size():
		return false

	if is_unlocked(path_name, node_index):
		return false

	if not is_available(path_name, node_index):
		return false

	var node: Dictionary = paths[path_name][node_index]
	var cost: Dictionary = node["cost"]

	if not Resources.spend_resources(cost):
		return false

	node["unlocked"] = true

	node_unlocked.emit(
		path_name,
		node["id"]
	)

	return true
