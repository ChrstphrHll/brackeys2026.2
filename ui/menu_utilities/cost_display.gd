extends HBoxContainer


@export var resource: String
@export var cost: int

@onready var cost_label = $Cost
@onready var texture_rect = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	cost_label.text = str(cost)
	texture_rect.texture = Resources.get_resource_icon(resource)
