extends Control

class_name Machine


@export var machine_name: String = "test"
var machine_icon: Resource
var current_task: String

var id: int = ResourceUID.create_id_for_path("machine_ids")

var speed = 1
var efficiency = 10

@onready var task_timer: Timer = $TaskTimer
@onready var task_selector = $MarginContainer/VBoxContainer/HBoxContainer/MenuButton
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	task_selector.get_popup().id_pressed.connect(_task_menu_trigger)
	Tasks.task_list.map(_add_task_option)
	build()
	
	ResourceUID.add_id(id, "machine_ids")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MarginContainer/VBoxContainer/ProgressBar.value = task_timer.time_left


func _task_menu_trigger(id: int):
	Tasks.task_list[id].start.call(self)


func _add_task_option(task):
	task_selector.get_popup().add_item(task.title)


func build():
	set_machine_name()
	set_icon()


func set_machine_name():
	$MarginContainer/VBoxContainer/HBoxContainer/MachineName.text = \
		machine_name


func set_icon():
	$MarginContainer/VBoxContainer/HBoxContainer/MachineIcon.texture = \
		machine_icon


func set_progress_bar_maximum(time_cost):
	if time_cost == -1:
		progress_bar.hide()
	else:
		progress_bar.max_value = time_cost


func implement_consequence(task_name):
	pass


func start_task(task_name: String, time_cost: int, bound_callback: Callable):
	Events.start_machine_task(self)
	current_task = task_name
	task_timer.timeout.connect(bound_callback)
	$MarginContainer/VBoxContainer/ProgressBar.max_value = time_cost
	task_timer.start(time_cost)


func end_task(bound_callback):
	Events.end_machine_task(self)
	implement_consequence(current_task)
	task_timer.timeout.disconnect(bound_callback)
	current_task = ""
