extends Node


signal machine_added


func add_machine(machine: Machine):
	machine_added.emit(machine)
