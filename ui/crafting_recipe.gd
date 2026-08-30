extends Button

@export var resource: String

@onready var crafting_recipe = $"."
@onready var resource_image = $MarginContainer/HBoxContainer/ResourceVBox/ResourceImage
@onready var resource_name = $MarginContainer/HBoxContainer/ResourceVBox/ResourceName
@onready var costs = $MarginContainer/HBoxContainer/Costs

var cost_helper = preload("res://ui/menu_utilities/cost_display.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.recipe_selected.connect(_on_recipe_selected)
	
	resource_image.texture = Resources.get_resource_icon(resource)
	resource_name.text = \
		Resources.get_resource_display_name(resource)
	
	var resource_costs = Resources.get_resource_crafting_cost(resource)
	assert(resource_costs != null, "Only craftable resources")
	
	for resource in resource_costs:
		var cost = resource_costs[resource]
		var instantiated_cost_helper = cost_helper.instantiate()
		
		instantiated_cost_helper.resource = resource
		instantiated_cost_helper.cost = cost
		
		costs.add_child(instantiated_cost_helper)


func _on_toggled(toggled_on):
	if toggled_on:
		print("its on now so were selectin", resource)
		Events.select_recipe(resource)
	# TODO this needs to properly unselect but not urgent


func _on_recipe_selected(resourceOrNull):
	if resourceOrNull != resource:
		crafting_recipe.button_pressed = false
