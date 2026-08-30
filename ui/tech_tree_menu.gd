extends Control


@onready var paths_container: VBoxContainer = \
	$OuterMargin/Panel/InnerMargin/VBox/Scroll/Paths

@onready var close_button: Button = \
	$OuterMargin/Panel/InnerMargin/VBox/Header/CloseButton


func _ready():
	close_button.pressed.connect(close_menu)
	TechTree.node_unlocked.connect(_on_node_unlocked)
	Zones.zone_changed.connect(
		func(_zone): _rebuild_tree()
	)

	_rebuild_tree()


func open_menu():
	_rebuild_tree()
	show()


func close_menu():
	hide()


func _on_node_unlocked(_path_name: String, _node_id: String):
	_rebuild_tree()


func _rebuild_tree():
	for child in paths_container.get_children():
		child.queue_free()

	for path_name in TechTree.get_path_names():
		_create_path(path_name)


func _create_path(path_name: String):
	var path_container = VBoxContainer.new()
	path_container.add_theme_constant_override("separation", 10)
	paths_container.add_child(path_container)

	# Path title
	var path_label = Label.new()
	path_label.text = path_name
	path_label.add_theme_font_size_override("font_size", 22)
	path_container.add_child(path_label)

	# Horizontal row of tech nodes.
	var node_row = HBoxContainer.new()
	node_row.add_theme_constant_override("separation", 0)
	path_container.add_child(node_row)

	var nodes = TechTree.get_nodes(path_name)

	for node_index in range(nodes.size()):
		# Put a connecting line before every node except the first.
		if node_index > 0:
			var connector = _create_connector(
				TechTree.is_unlocked(path_name, node_index - 1)
			)

			node_row.add_child(connector)

		var node_button = _create_node_button(
			path_name,
			node_index,
			nodes[node_index]
		)

		node_row.add_child(node_button)


func _create_connector(active: bool) -> Control:
	var holder = CenterContainer.new()
	holder.custom_minimum_size = Vector2(48, 80)

	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(48, 4)

	if active:
		line.color = Color(0.75, 0.65, 1.0)
	else:
		line.color = Color(0.35, 0.35, 0.35)

	holder.add_child(line)

	return holder


func _create_node_button(
	path_name: String,
	node_index: int,
	node_data: Dictionary
) -> Button:
	var button = Button.new()

	button.custom_minimum_size = Vector2(80, 80)
	button.focus_mode = Control.FOCUS_NONE
	
	button.text = node_data["name"]

	button.custom_minimum_size = Vector2(
		150,
		80
	)

	button.autowrap_mode = \
		TextServer.AUTOWRAP_WORD_SMART

	button.tooltip_text = _build_tooltip(
		path_name,
		node_index,
		node_data
	)

	button.pressed.connect(
		_on_node_pressed.bind(path_name, node_index)
	)

	_apply_node_style(
		button,
		path_name,
		node_index
	)

	return button


func _on_node_pressed(path_name: String, node_index: int):
	if TechTree.unlock_node(path_name, node_index):
		_rebuild_tree()


func _apply_node_style(
	button: Button,
	path_name: String,
	node_index: int
):
	var unlocked = TechTree.is_unlocked(path_name, node_index)
	var available = TechTree.is_available(path_name, node_index)

	var normal_style: StyleBoxFlat
	var hover_style: StyleBoxFlat

	if unlocked:
		# Purchased
		normal_style = _make_node_style(
			Color(0.30, 0.55, 0.35),
			Color(0.55, 0.9, 0.6)
		)

		hover_style = _make_node_style(
			Color(0.35, 0.65, 0.40),
			Color(0.65, 1.0, 0.7)
		)

	elif available:
		# Can potentially be purchased
		normal_style = _make_node_style(
			Color(0.35, 0.28, 0.50),
			Color(0.75, 0.65, 1.0)
		)

		hover_style = _make_node_style(
			Color(0.45, 0.35, 0.65),
			Color(0.9, 0.8, 1.0)
		)

	else:
		# Previous node has not been unlocked
		normal_style = _make_node_style(
			Color(0.22, 0.22, 0.22),
			Color(0.38, 0.38, 0.38)
		)

		hover_style = _make_node_style(
			Color(0.25, 0.25, 0.25),
			Color(0.45, 0.45, 0.45)
		)

	button.add_theme_stylebox_override(
		"normal",
		normal_style
	)

	button.add_theme_stylebox_override(
		"hover",
		hover_style
	)

	button.add_theme_stylebox_override(
		"pressed",
		hover_style
	)

	button.add_theme_stylebox_override(
		"focus",
		normal_style
	)


func _make_node_style(
	background_color: Color,
	border_color: Color
) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()

	style.bg_color = background_color
	style.border_color = border_color

	style.set_border_width_all(3)
	style.set_corner_radius_all(14)

	return style


func _build_tooltip(
	path_name: String,
	node_index: int,
	node_data: Dictionary
) -> String:
	var cost_text = _format_cost(node_data["cost"])

	var state_text: String = \
	TechTree.get_node_state_text(
		path_name,
		node_index
	)

	if TechTree.is_unlocked(path_name, node_index):
		state_text = "Unlocked"

	elif not TechTree.is_available(path_name, node_index):
		state_text = "Locked - unlock the previous node first"

	elif Resources.can_afford(node_data["cost"]):
		state_text = "Click to unlock"

	else:
		state_text = "Not enough resources"

	return "%s\n%s\n\nCost: %s\n%s" % [
		node_data["name"],
		node_data["description"],
		cost_text,
		state_text
	]


func _format_cost(costs: Dictionary) -> String:
	var pieces: PackedStringArray = []

	for resource_name in costs:
		pieces.append(
			"%d %s" % [
				costs[resource_name],
				Resources.get_resource_display_name(
					resource_name
				)
			]
		)

	return ", ".join(pieces)
