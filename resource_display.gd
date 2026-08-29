extends HBoxContainer

var resource_entries: Dictionary = {}


func _ready():
	Resources.resource_changed.connect(_on_resource_changed)

	for resource_name in Resources.get_resource_names():
		create_resource_entry(resource_name)


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
	name_label.text = resource_name.capitalize()
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


func _on_resource_changed(resource_name: String, new_amount: int):
	# allows code to work if a resource is introduced
	# after the UI has already loaded
	if not resource_entries.has(resource_name):
		create_resource_entry(resource_name)

	update_resource_entry(resource_name, new_amount)


func update_resource_entry(resource_name: String, amount: int):
	var entry = resource_entries[resource_name]
	entry["amount_label"].text = str(amount)
