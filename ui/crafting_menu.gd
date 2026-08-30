extends Control

@onready var grid_container = \
	$OuterMargin/Panel/InnerMargin/VBox/HBoxContainer/ResourceVBox/ResourceScrollBox/GridContainer
@onready var craft_button = \
	$OuterMargin/Panel/InnerMargin/VBox/HBoxContainer/MachineVBox/CraftButton
@onready var machine_options = \
	$OuterMargin/Panel/InnerMargin/VBox/HBoxContainer/MachineVBox/MachineOptions


signal machine_selected

var recipe_scene = preload("res://ui/crafting_recipe.tscn")
var machine_scene = preload("res://machines/machine.tscn")
var known_recipes: Dictionary = {}
var selected_recipe = null

var currently_available_machines = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.machine_added.connect(_add_available_machine)
	Events.machine_task_ended.connect(_add_available_machine)
	
	Events.machine_lost.connect(_lose_available_machine)
	Events.machine_task_started.connect(_lose_available_machine)
	
	Events.recipe_unlocked.connect(_new_crafting_recipe)
	Events.recipe_selected.connect(_set_selected_recipe)
	
	Zones.zone_changed.connect(
		_refresh_recipes
	)
	_refresh_recipes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_button_pressed():
	hide()


func _update_craft_button_state() -> void:
	craft_button.disabled = (
		selected_recipe == null
		or machine_options.item_count == 0
	)


func _new_crafting_recipe(resource):
	if known_recipes.has(resource):
		return

	known_recipes[resource] = true

	var instantiated_recipe = \
		recipe_scene.instantiate()

	instantiated_recipe.resource = resource

	grid_container.add_child(
		instantiated_recipe
	)


func _set_selected_recipe(resource_or_null):
	selected_recipe = resource_or_null
	_update_craft_button_state()


func _add_available_machine(machine: Machine):
	if currently_available_machines.has(machine.id):
		return

	machine_options.add_item(
		machine.machine_name,
		machine.id
	)

	currently_available_machines[machine.id] = machine

	if machine_options.item_count == 1:
		machine_options.select(0)

	_update_craft_button_state()


func _lose_available_machine(machine: Machine):
	if not currently_available_machines.has(machine.id):
		return

	var item_index: int = machine_options.get_item_index(machine.id)

	if item_index >= 0:
		machine_options.remove_item(item_index)

	currently_available_machines.erase(machine.id)

	if machine_options.item_count > 0:
		machine_options.select(0)

	_update_craft_button_state()


func _on_craft_button_pressed():
	if selected_recipe == null:
		return

	if machine_options.item_count == 0:
		push_warning("Tried to craft with no available machine.")
		_update_craft_button_state()
		return

	var selected_machine_id: int = machine_options.get_selected_id()

	if not currently_available_machines.has(selected_machine_id):
		push_error(
            "Selected crafting machine does not exist: %s"
			% selected_machine_id
		)
		_update_craft_button_state()
		return

	var costs_value = \
		Resources.get_resource_crafting_cost(selected_recipe)

	if costs_value == null:
		push_error(
            "No crafting cost for resource: %s"
			% selected_recipe
		)
		return

	var costs: Dictionary = costs_value

	if not Resources.can_afford(costs):
		print("Can't afford ", selected_recipe)
		return

	var selected_machine: Machine = \
		currently_available_machines[selected_machine_id]

	Tasks.start_craft_task(
		selected_recipe,
		selected_machine
	)

	hide()


func _on_machine_options_item_selected(index):
	pass # Replace with function body.
	

func _refresh_recipes(_zone: int = -1):
	for resource in Resources.get_craftable_resources():
		_new_crafting_recipe(resource)
