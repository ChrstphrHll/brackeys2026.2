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
	task_selector.get_popup().add_item("test item", 100111, 1)
	task_selector.get_popup().add_item("test ew")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MarginContainer/VBoxContainer/ProgressBar.value = task_timer.time_left


func _task_menu_trigger(id: int):
	print(id)


func implement_consequence(task_name):
	pass


func _on_button_pressed():
	Tasks.start_gather_task("wood", self)


func start_task(task_name: String, time_cost: int, bound_callback: Callable):
	current_task = task_name
	task_timer.timeout.connect(bound_callback)
	task_timer.start(time_cost)


func end_task(bound_callback):
	implement_consequence(current_task)
	task_timer.timeout.disconnect(bound_callback)
	current_task = ""
