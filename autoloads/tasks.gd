extends Node


var task_list = Resources.get_resource_names().map(gather_task_factory)


func gather_task_factory(resource):
	return {
		"title": "Gather " + resource,
		"progressing_title": "Gathering " + resource,
		"start": start_gather_factory(resource),
		"end": end_gather_factory(resource)
	}


func start_gather_factory(resource):
	return func (machine: Machine): start_gather_task(resource, machine)


func end_gather_factory(resource):
	return func (machine: Machine): end_gather_task(resource, machine)


func start_gather_task(resource, machine: Machine):
	var task_name = "Gathering " + resource
	
	var difficulty = Resources.get_resource_difficulty(resource)
	var time_cost = difficulty * machine.speed
	
	machine.task_timer.start(time_cost)
	machine.start_task(task_name, time_cost, end_gather_task.bind(resource, machine))
	machine.task_timer.timeout.connect(end_gather_task.bind(resource, machine))


func end_gather_task(resource, machine: Machine):
	var abundance = Resources.get_resource_abundance(resource)
	var resource_gain = abundance * machine.efficiency
	
	Resources.modify_resource(resource, resource_gain)
	machine.end_task(end_gather_task)
