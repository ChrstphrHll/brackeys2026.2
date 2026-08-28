extends Control

class_name Machine

@export var machine_name: String = "test"
var current_task: String

var speed = 1
var efficiency = 10

@onready var task_timer: Timer = $TaskTimer
@onready var task_selector = $MarginContainer/VBoxContainer/HBoxContainer/MenuButton

# Called when the node enters the scene tree for the first time.
func _ready():
	task_selector.get_popup().id_pressed.connect(_task_menu_trigger)
	var tasks = Tasks.task_list.map(_add_task_option)
	
	$MarginContainer/VBoxContainer/HBoxContainer/MachineName.text = machine_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MarginContainer/VBoxContainer/ProgressBar.value = task_timer.time_left


func _task_menu_trigger(id: int):
	Tasks.task_list[id].start.call(self)


func _add_task_option(task):
	task_selector.get_popup().add_item(task.title)


func implement_consequence(task_name):
	pass


func start_task(task_name: String, time_cost: int, bound_callback: Callable):
	current_task = task_name
	task_timer.timeout.connect(bound_callback)
	$MarginContainer/VBoxContainer/ProgressBar.max_value = time_cost
	task_timer.start(time_cost)


func end_task(bound_callback):
	implement_consequence(current_task)
	task_timer.timeout.disconnect(bound_callback)
	current_task = ""
