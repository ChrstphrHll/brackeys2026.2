extends Node

const machine_scene = preload("res://machines/machine.tscn")

func get_scavenge_result(efficiency) -> Machine:
	var instance = machine_scene.instantiate()
	instance.machine_name = "new guy!!"
	
	return instance
