extends Panel

@export var resource: String

@onready var resource_image = $MarginContainer/HBoxContainer/ResourceVBox/ResourceImage
@onready var resource_name = $MarginContainer/HBoxContainer/ResourceVBox/ResourceName
@onready var costs = $MarginContainer/HBoxContainer/Costs

var cost_helper = preload("res://ui/menu_utilities/cost_display.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	resource_image.texture = Resources.get_resource_icon(resource)
	resource_name.text = resource
	
	var resource_costs = Resources.get_resource_crafting_cost(resource)
	
	for resource in resource_costs:
		var cost = resource_costs[resource]
		var instantiated_cost_helper = cost_helper.instantiate()
		
		instantiated_cost_helper.resource = resource
		instantiated_cost_helper.cost = cost
		
		costs.add_child(instantiated_cost_helper)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
