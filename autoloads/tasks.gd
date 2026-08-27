extends Node


func start_gather_task(resource, machine: Machine):
	var task_name = "Gathering " + resource
	
	var difficulty = Resources.get_resource_difficulty(resource)
	var time_cost = difficulty * machine.speed
	
	machine.task_timer.start(time_cost)
	machine.start_task(task_name, time_cost, finish_gather_task.bind(resource, machine))
	machine.task_timer.timeout.connect(finish_gather_task.bind(resource, machine))


func finish_gather_task(resource, machine: Machine):
	var abundance = Resources.get_resource_abundance(resource)
	var resource_gain = abundance * machine.efficiency
	
	Resources.modify_resource(resource, resource_gain)
	machine.end_task(finish_gather_task)
	machine.task_timer.timeout.disconnect(finish_gather_task)
