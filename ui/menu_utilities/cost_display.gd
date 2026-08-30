extends HBoxContainer


@export var resource: String
@export var cost: int

@onready var cost_label = $Cost
@onready var texture_rect = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	cost_label.text = "%d %s" % [
		cost,
		Resources.get_resource_display_name(resource)
	]

	var icon_texture = \
		Resources.get_resource_icon(resource)

	texture_rect.texture = icon_texture
	texture_rect.visible = icon_texture != null
	texture_rect.texture = Resources.get_resource_icon(resource)
