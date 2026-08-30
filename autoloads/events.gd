extends Node


signal machine_added
signal machine_task_started
signal machine_task_ended
signal machine_lost

signal recipe_unlocked
signal recipe_selected

signal final_cutscene_ended


func add_machine(machine: Machine):
	machine_added.emit(machine)


func lose_machine(machine: Machine):
	machine_lost.emit(machine)


func start_machine_task(machine: Machine):
	machine_task_started.emit(machine)


func end_machine_task(machine: Machine):
	machine_task_ended.emit(machine)


func unlock_recipe(resource: String):
	recipe_unlocked.emit(resource)


func select_recipe(resourceOrNull):
	recipe_selected.emit(resourceOrNull) 


func end_game():
	final_cutscene_ended.emit()
