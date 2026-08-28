extends Node2D


# Control how far the player can zoom.
@export var min_zoom: float = 0.30
@export var max_zoom: float = 0.80
@export var zoom_step: float = 0.05


var dragging: bool = false


func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse buttons.
	if event is InputEventMouseButton:

		# Left-click and drag = pan the map.
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

			if dragging:
				get_viewport().set_input_as_handled()

		# Mouse wheel up = zoom in.
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at_mouse(zoom_step)
			get_viewport().set_input_as_handled()

		# Mouse wheel down = zoom out.
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at_mouse(-zoom_step)
			get_viewport().set_input_as_handled()


	# Handle dragging.
	elif event is InputEventMouseMotion and dragging:

		# Prevents the map from getting stuck
		# in dragging mode if the mouse was released over some UI
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			position += event.relative
			get_viewport().set_input_as_handled()
		else:
			dragging = false


func _zoom_at_mouse(zoom_change: float) -> void:
	var old_zoom: float = scale.x

	var new_zoom: float = clampf(
		old_zoom + zoom_change,
		min_zoom,
		max_zoom
	)

	if is_equal_approx(old_zoom, new_zoom):
		return

	# Find where the mouse is on the screen.
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	# Determine which point on the map is underneath the mouse.
	var point_on_map: Vector2 = \
		(mouse_position - position) / old_zoom

	# Apply the new zoom.
	scale = Vector2(new_zoom, new_zoom)

	# Reposition the map so the same point remains underneath
	# the mouse cursor while zooming.
	position = \
		mouse_position - point_on_map * new_zoom
