extends Control

@onready var grid_container = \
	$OuterMargin/Panel/InnerMargin/VBox/HBoxContainer/ResourceVBox/ResourceScrollBox/GridContainer
@onready var craft_button = \
	$OuterMargin/Panel/InnerMargin/VBox/HBoxContainer/MachineVBox/CraftButton
@onready var machine_vbox_container = \
	$OuterMargin/Panel/InnerMargin/VBox/HBoxContainer/MachineVBox/MachineScrollContainer/VBoxContainer

signal machine_selected

var recipe_scene = preload("res://ui/crafting_recipe.tscn")
var machine_scene = preload("res://machines/machine.tscn")

var selected_recipe = null
var selected_machine = null

var currently_available_machines = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.machine_added.connect(_add_available_machine)
	Events.machine_task_ended.connect(_add_available_machine)
	
	Events.machine_lost.connect(_lose_available_machine)
	Events.machine_task_started.connect(_lose_available_machine)
	
	Events.recipe_unlocked.connect(_new_crafting_recipe)
	Events.recipe_selected.connect(_set_selected_recipe)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_button_pressed():
	hide()


func _new_crafting_recipe(resource):
	var instantiated_recipe = recipe_scene.instantiate()
	instantiated_recipe.resource = resource
	
	instantiated_recipe.gui_input.connect(_test)
	
	grid_container.add_child(instantiated_recipe)


func _set_selected_recipe(resourceOrNull):
	selected_recipe = resourceOrNull
	if not selected_recipe:
		craft_button.disabled = true
	else:
		craft_button.disabled = false


func _test():
	print("woha")


func _add_available_machine(machine: Machine):
	var machine_selector = Button.new()
	machine_selector.text = machine.machine_name
	machine_selector.toggle_mode = true
	machine_selector.toggled.connect(_set_selected_machine.bind(machine))
	machine_selected.connect(_set_machine_toggle.bind(machine, machine_selector))
	
	machine_vbox_container.add_child(machine_selector)
	
	currently_available_machines[machine] = machine_selector


func _set_machine_toggle(selected_machine, machine, machine_selector):
	print("comparing ", machine, " with ", selected_machine)
	if not selected_machine == machine:
		machine_selector.button_pressed = false


func _set_selected_machine(toggled_on, machine: Machine):
	machine_selected.emit(machine)


func _lose_available_machine(machine: Machine):
	if currently_available_machines.has(machine):
		currently_available_machines[machine].queue_free()
		currently_available_machines.erase(machine)
