extends Node


@onready var machines = [$UI/Machines/Machine]
var machine_scene = preload("res://machines/machine.tscn")


@onready var machines = [
	$UI/Machines/Machine
]


# TECH TREE
# -------------------------

@onready var tech_tree_button: Button = \
	$UI/TechTreeButton

@onready var tech_tree_menu = \
	$UI/TechTreeMenu


# ZONE MAP ANCHORS
# -------------------------

@onready var zone_anchors = [
	$MapWorld/ZoneAnchors/SwampAnchor,
	$MapWorld/ZoneAnchors/RavineAnchor,
	$MapWorld/ZoneAnchors/CityAnchor
]


# ZONE BUTTONS
# -------------------------

@onready var zone_buttons = [
	$UI/MapMarkers/SwampTransition,
	$UI/MapMarkers/RavineTransition,
	$UI/MapMarkers/CityTransition
]


@onready var zone_confirm_dialog: ConfirmationDialog = \
	$UI/ZoneConfirmDialog


var pending_transition_index: int = -1


func _ready() -> void:
	tech_tree_button.pressed.connect(
		tech_tree_menu.open_menu
	)
	Events.machine_added.connect(_on_machine_added)
	add_new_machine()

func add_new_machine():
	var instantiated_machine = machine_scene.instantiate()
	instantiated_machine.machine_name = "You"
	Events.add_machine(instantiated_machine)


	Events.machine_added.connect(
		_on_machine_added
	)


	# Connect each map transition button.
	for i in range(zone_buttons.size()):
		zone_buttons[i].pressed.connect(
			_on_zone_button_pressed.bind(i)
		)


	# Called when the player presses Advance
	# in the confirmation dialog.
	zone_confirm_dialog.confirmed.connect(
		_on_zone_confirmed
	)


	# Update the buttons whenever progression changes.
	Zones.zone_changed.connect(
		_refresh_zone_buttons
	)


	_refresh_zone_buttons()


func _process(_delta: float) -> void:
	_update_zone_button_positions()



# KEEP MAP BUTTONS ATTACHED TO THEIR MAP LOCATIONS
# --------------------------------------------------

func _update_zone_button_positions() -> void:
	for i in range(zone_buttons.size()):
		var button: Button = zone_buttons[i]
		var anchor: Marker2D = zone_anchors[i]

		# Marker2D's global position already includes
		# MapWorld's current pan and zoom.
		#
		# Subtracting half the button size centers the
		# button over the anchor.
		button.global_position = \
			anchor.global_position - button.size / 2.0


# ZONE TRANSITIONS
# --------------------------------------------------

func _on_zone_button_pressed(index: int) -> void:
	pending_transition_index = index

	var zone_name: String = \
		Zones.get_transition_name(index)

	var cost: Dictionary = \
		Zones.get_transition_cost(index)

	var affordable: bool = \
		Resources.can_afford(cost)


	zone_confirm_dialog.title = \
		"Advance to %s?" % zone_name


	zone_confirm_dialog.dialog_text = \
		"Advance to %s?\n\nCost: %s" % [
			zone_name,
			_format_cost(cost)
		]


	if not affordable:
		zone_confirm_dialog.dialog_text += \
            "\n\nYou do not have enough resources."


	zone_confirm_dialog.get_ok_button().text = \
        "Advance"

	zone_confirm_dialog.get_ok_button().disabled = \
		not affordable


	zone_confirm_dialog.popup_centered()


func _on_zone_confirmed() -> void:
	if pending_transition_index < 0:
		return

	Zones.unlock_transition(
		pending_transition_index
	)

	pending_transition_index = -1


func _refresh_zone_buttons(
	_new_zone: int = -1
) -> void:

	for i in range(zone_buttons.size()):
		var button: Button = zone_buttons[i]

		var zone_name: String = \
			Zones.get_transition_name(i)

		var cost: Dictionary = \
			Zones.get_transition_cost(i)


		# Already purchased transition:
		# make the marker disappear completely.
		if Zones.is_transition_unlocked(i):
			button.hide()
			continue


		button.show()


		# The next transition is usable.
		if Zones.is_transition_available(i):

			button.disabled = false

			button.text = \
				"Unlock %s\n%s" % [
					zone_name,
					_format_cost(cost)
				]


		# Later transitions are visible but locked.
		else:

			button.disabled = true

			button.text = \
				"%s\nLOCKED" % zone_name


func _format_cost(costs: Dictionary) -> String:
	var pieces := PackedStringArray()

	for resource_name in costs:
		pieces.append(
			"%d %s" % [
				costs[resource_name],
				str(resource_name).capitalize()
			]
		)

	return ", ".join(pieces)


# EXISTING CODE
# ----------------------------

func _on_main_menu_pressed() -> void:
	SceneManager.go_to("main_menu")


func _on_machine_added(machine: Machine) -> void:
	$UI/Machines.add_child(machine)


func _on_crafting_button_pressed():
	$UI/CraftingMenu.show()


func add_new_machine() -> void:
	var test_machine = Machine.new()
	machines.push_back(test_machine)
