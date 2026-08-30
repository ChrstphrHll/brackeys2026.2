extends Node


func get_tasks_for_machine(machine: Machine) -> Array[Dictionary]:
	var available_tasks: Array[Dictionary] = []

	# Only the human can scavenge.
	if machine.is_player:
		available_tasks.append({
			"title": "Scavenge",
			"start": func(selected_machine: Machine):
				start_scavenge_task(selected_machine)
		})

	# Gathering tasks depend on the current zone.
	for resource: String in Resources.get_gatherable_resources():
		available_tasks.append({
			"title": "Gather %s" % Resources.get_resource_display_name(resource),

			"start": func(selected_machine: Machine):
				start_gather_task(
					resource,
					selected_machine
				)
		})

	return available_tasks


# -------------------------------------------------
# GATHERING
# -------------------------------------------------

func start_gather_task(
	resource: String,
	machine: Machine
) -> void:

	var difficulty: float = float(
		Resources.get_resource_difficulty(resource)
	)

	var machine_speed: float = float(
		machine.get_effective_speed()
	)

	var time_cost: float = difficulty / machine_speed

	machine.start_task(
		"Gathering %s" % Resources.get_resource_display_name(resource),
		time_cost,
		end_gather_task.bind(
			resource,
			machine
		)
	)


func end_gather_task(
	resource: String,
	machine: Machine
) -> void:

	var base_yield: int = int(
		Resources.get_resource_base_yield(resource)
	)

	var machine_efficiency: float = float(
		machine.get_effective_efficiency()
	)

	var zone_multiplier: float = float(
		Zones.get_gather_multiplier()
	)

	var total_yield: float = (
		float(base_yield)
		* machine_efficiency
		* zone_multiplier
	)

	var resource_gain: int = max(
		1,
		int(round(total_yield))
	)

	Resources.modify_resource(
		resource,
		resource_gain
	)

	machine.finish_task()

	# Recovered machines eventually become autonomous.
	if (
		not machine.is_player
		and TechTree.machine_auto_repeat
	):
		start_gather_task(
			resource,
			machine
		)


# -------------------------------------------------
# SCAVENGING
# -------------------------------------------------

func start_scavenge_task(machine: Machine) -> void:
	var base_time: float = 6.0

	var scavenge_multiplier: float = float(
		TechTree.scavenge_time_multiplier
	)

	var machine_speed: float = float(
		machine.get_effective_speed()
	)

	var time_cost: float = (
		base_time
		* scavenge_multiplier
		/ machine_speed
	)

	machine.start_task(
		"Scavenging",
		time_cost,
		end_scavenge_task.bind(machine)
	)


func end_scavenge_task(machine: Machine) -> void:
	machine.finish_task()

	var result: Dictionary = Zones.roll_scavenge()

	match result["type"]:

		"machine":
			var new_machine: Machine = Zones.create_scavenged_machine()

			Events.add_machine(new_machine)

		"resource":
			var resource_name: String = str(
				result["resource"]
			)

			var amount: int = int(
				result["amount"]
			)

			Resources.modify_resource(
				resource_name,
				amount
			)

		"nothing":
			pass

	Events.report_scavenge(
		str(result["message"])
	)


# -------------------------------------------------
# CRAFTING
# -------------------------------------------------

func start_craft_task(
	resource: String,
	machine: Machine
) -> void:

	if machine.is_busy():
		return

	var costs_value = Resources.get_resource_crafting_cost(resource)

	if costs_value == null:
		return

	var costs: Dictionary = costs_value

	# Spend ingredients when crafting begins.
	if not Resources.spend_resources(costs):
		return

	var difficulty: float = float(
		Resources.get_resource_difficulty(resource)
	)

	var machine_speed: float = float(
		machine.get_effective_speed()
	)

	var time_cost: float = difficulty / machine_speed

	var started: bool = machine.start_task(
		"Crafting %s" % Resources.get_resource_display_name(resource),
		time_cost,
		end_craft_task.bind(
			resource,
			machine
		)
	)

	# Refund ingredients if the task somehow failed to start.
	if not started:
		for resource_name: String in costs:
			Resources.modify_resource(
				resource_name,
				int(costs[resource_name])
			)


func end_craft_task(
	resource: String,
	machine: Machine
) -> void:

	Resources.modify_resource(
		resource,
		1
	)

	machine.finish_task()
