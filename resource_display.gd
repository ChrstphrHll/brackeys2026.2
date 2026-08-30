extends HBoxContainer

var resource_entries: Dictionary = {}

@onready var resource_background: ColorRect = \
	$"../ResourceBackground"

const BACKGROUND_PADDING_LEFT: float = 9.0
const BACKGROUND_PADDING_TOP: float = 7.0
const BACKGROUND_PADDING_RIGHT: float = 9.0
const BACKGROUND_PADDING_BOTTOM: float = 7.0
const MIN_BACKGROUND_SIZE: Vector2 = Vector2(501.0, 109.0)


func _ready():
	Resources.resource_changed.connect(
		_on_resource_changed
	)

	Zones.zone_changed.connect(
		_on_zone_changed
	)

	_add_visible_resources()
	call_deferred("_resize_resource_background")


func create_resource_entry(resource_name: String):
	# prevent duplicate resources
	if resource_entries.has(resource_name):
		return

	# Each resource gets one vertical column.
	var column = VBoxContainer.new()
	add_child(column)

	# Optional icon
	var icon = TextureRect.new()

	icon.custom_minimum_size = Vector2(56, 56)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	column.add_child(icon)

	var icon_texture = Resources.get_resource_icon(resource_name)
	icon.texture = icon_texture
	icon.visible = icon_texture != null

	# Resource name
	var name_label = Label.new()
	name_label.text = \
	Resources.get_resource_display_name(resource_name)
	name_label.add_theme_font_size_override("font_size", 11)
	column.add_child(name_label)

	# Resource amount
	var amount_label = Label.new()
	amount_label.add_theme_font_size_override("font_size", 13)
	column.add_child(amount_label)

	# Remember all the UI objects associated with this resource
	resource_entries[resource_name] = {
		"column": column,
		"icon": icon,
		"name_label": name_label,
		"amount_label": amount_label
	}

	update_resource_entry(
		resource_name,
		Resources.get_resource_amount(resource_name)
	)

	call_deferred("_resize_resource_background")


func _on_resource_changed(resource_name: String, new_amount: int):
	# allows code to work if a resource is introduced
	# after the UI has already loaded
	if not resource_entries.has(resource_name):
		create_resource_entry(resource_name)

	update_resource_entry(resource_name, new_amount)


func update_resource_entry(resource_name: String, amount: int):
	var entry = resource_entries[resource_name]
	entry["amount_label"].text = str(amount)
	


func _on_zone_changed(_zone: int):
	_add_visible_resources()


func _add_visible_resources():
	for resource_name in \
		Resources.get_visible_resource_names():

		create_resource_entry(
			resource_name
		)


func _resize_resource_background() -> void:
	var content_size: Vector2 = get_combined_minimum_size()

	resource_background.position = position - Vector2(
		BACKGROUND_PADDING_LEFT,
		BACKGROUND_PADDING_TOP
	)

	var desired_size: Vector2 = Vector2(
		content_size.x
			+ BACKGROUND_PADDING_LEFT
			+ BACKGROUND_PADDING_RIGHT,
		content_size.y
			+ BACKGROUND_PADDING_TOP
			+ BACKGROUND_PADDING_BOTTOM
	)

	resource_background.size = Vector2(
		max(MIN_BACKGROUND_SIZE.x, desired_size.x),
		max(MIN_BACKGROUND_SIZE.y, desired_size.y)
	)
