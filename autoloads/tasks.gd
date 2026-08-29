extends Node


var task_list = Resources.get_gatherable_resources().map(gather_task_factory) + [
	{
		"title": "Scavenge",
		"start": start_scavenge_task,
		"end": end_scavenge_task,
	}
]


func start_craft_task(resource, machine: Machine):
	var task_name = "Crafting " + resource
	
	var difficulty = Resources.get_resource_difficulty(resource)
	var time_cost = difficulty * machine.speed
	
	machine.start_task(task_name, time_cost, end_craft_task.bind(resource, machine))


func end_craft_task(resource, machine: Machine):
	var costs = Resources.get_resource_crafting_cost(resource)
	if not Resources.can_afford(costs):
		print("cant affor ", resource)
	
	Resources.spend_resources(costs)
	Resources.modify_resource(resource, 1)
	machine.end_task(end_craft_task)


func gather_task_factory(resource):
	return {
		"title": "Gather " + resource,
		"start": start_gather_factory(resource),
		"end": end_gather_factory(resource),
		"sidebar": true
	}


func is_sidebar_task(task) -> bool:
	return task.has("sidebar") and task.sidebar


func start_gather_factory(resource):
	return func (machine: Machine): start_gather_task(resource, machine)


func end_gather_factory(resource):
	return func (machine: Machine): end_gather_task(resource, machine)


func start_gather_task(resource, machine: Machine):
	var task_name = "Gathering " + resource
	
	var difficulty = Resources.get_resource_difficulty(resource)
	var time_cost = difficulty * machine.speed
	print("gathering start")
	machine.start_task(task_name, time_cost, end_gather_task.bind(resource, machine))


func end_gather_task(resource, machine: Machine):
	print("gathering end")
	var abundance = Resources.get_resource_abundance(resource)
	var resource_gain = abundance * machine.efficiency
	
	Resources.modify_resource(resource, resource_gain)
	machine.end_task(end_gather_task)


func start_scavenge_task(machine: Machine):
	const progressing_title = "Scavenging"
	
	machine.start_task(progressing_title, 1, end_scavenge_task.bind(machine))
	

func end_scavenge_task(machine: Machine):
	machine.end_task(end_scavenge_task)
	var scavenge_result = Zones.get_scavenge_result(machine.efficiency)
	
	Events.add_machine(scavenge_result)
