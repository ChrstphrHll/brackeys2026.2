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


func _set_selected_recipe(resourceOrNull):
	selected_recipe = resourceOrNull
	if not selected_recipe:
		craft_button.disabled = true
	else:
		craft_button.disabled = false


func _add_available_machine(machine: Machine):
	if currently_available_machines.has(machine.id):
		return

	machine_options.add_item(
		machine.machine_name,
		machine.id
	)

	var item_index: int = int(
		machine_options.get_item_index(machine.id)
	)

	machine_options.set_item_metadata(
		item_index,
		machine.id
	)

	currently_available_machines[machine.id] = machine


func _lose_available_machine(machine: Machine):
	if not currently_available_machines.has(machine.id):
		return

	var item_index: int = int(
		machine_options.get_item_index(machine.id)
	)

	if item_index >= 0:
		machine_options.remove_item(item_index)

	currently_available_machines.erase(machine.id)


func _on_craft_button_pressed():
	var selected_machine_id = machine_options.get_selected_metadata()
	var costs = Resources.get_resource_crafting_cost(selected_recipe)
	var canAfford = Resources.can_afford(costs)
	
	if not canAfford:
		print("cant afford ", selected_recipe)
		return
	
	Tasks.start_craft_task(selected_recipe, currently_available_machines[selected_machine_id])
	hide()


func _on_machine_options_item_selected(index):
	pass # Replace with function body.
	

func _refresh_recipes(_zone: int = -1):
	for resource in Resources.get_craftable_resources():
		_new_crafting_recipe(resource)
