extends Control

class_name Machine


static var next_machine_id: int = 1


var machine_images = [
	preload("res://assets/machines/Bulldozer2.png"),
	preload("res://assets/machines/image_29.png"),
	preload("res://assets/machines/image_31.png"),
	preload("res://assets/machines/image_33.png"),
	preload("res://assets/machines/image_34.png"),
	preload("res://assets/machines/image_35.png"),
	preload("res://assets/machines/Tractor2.png"),
	preload("res://assets/machines/wagon.png"),
	preload("res://assets/Bulldozer.png")
]


@export var machine_name: String = "Machine"
@export var machine_icon: Texture2D = _get_random_machine()

@export var is_player: bool = false

@export var base_speed: float = 1.0
@export var base_efficiency: float = 1.0


var id: int
var current_task: String = ""

var task_menu_entries: Array[Dictionary] = []

var completion_callback: Callable


@onready var task_timer: Timer = $TaskTimer

@onready var task_selector: MenuButton = \
	$MarginContainer/VBoxContainer/HBoxContainer/MenuButton

@onready var progress_bar: ProgressBar = \
	$MarginContainer/VBoxContainer/ProgressBar


func _init():
	id = next_machine_id
	next_machine_id += 1


func _get_random_machine():
	var index = randi() % machine_images.size()


func _ready():
	var popup := task_selector.get_popup()

	popup.id_pressed.connect(_task_menu_trigger)
	popup.about_to_popup.connect(_refresh_task_menu)

	build()

	progress_bar.hide()

	task_selector.text = "Task"


func _process(_delta):
	if not task_timer.is_stopped():
		progress_bar.value = \
			progress_bar.max_value - task_timer.time_left


func _refresh_task_menu():
	var popup := task_selector.get_popup()

	popup.clear()

	task_menu_entries = Tasks.get_tasks_for_machine(self)

	for i in range(task_menu_entries.size()):
		popup.add_item(
			task_menu_entries[i]["title"],
			i
		)


func _task_menu_trigger(task_id: int):
	if task_id < 0 or task_id >= task_menu_entries.size():
		return

	task_menu_entries[task_id]["start"].call(self)


func build():
	set_machine_name()
	set_icon()


func set_machine_name():
	$MarginContainer/VBoxContainer/HBoxContainer/MachineName.text = \
		machine_name


func set_icon():
	if machine_icon != null:
		$MarginContainer/VBoxContainer/HBoxContainer/MachineIcon.texture = \
			machine_icon


func get_effective_speed() -> float:
	if is_player:
		return base_speed

	return base_speed * TechTree.machine_speed_multiplier


func get_effective_efficiency() -> float:
	if is_player:
		return base_efficiency

	return base_efficiency * TechTree.machine_yield_multiplier


func is_busy() -> bool:
	return not task_timer.is_stopped()


func start_task(
	task_name: String,
	time_cost: float,
	on_complete: Callable
) -> bool:

	if is_busy():
		return false

	current_task = task_name
	completion_callback = on_complete

	task_selector.disabled = true
	task_selector.text = task_name

	progress_bar.show()
	progress_bar.max_value = time_cost
	progress_bar.value = 0

	Events.start_machine_task(self)

	task_timer.start(time_cost)

	return true


func _on_task_timer_timeout():
	var callback := completion_callback

	completion_callback = Callable()

	if callback.is_valid():
		callback.call()


func finish_task():
	current_task = ""

	task_selector.disabled = false
	task_selector.text = "Task"

	progress_bar.hide()

	Events.end_machine_task(self)
