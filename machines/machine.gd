extends Control

class_name Machine

var machine_info: Machines.MachineInfo

@onready var task_timer: Timer = $TaskTimer
@onready var task_selector = $MarginContainer/VBoxContainer/HBoxContainer/MenuButton
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.machine_task_started.connect(build_on_change)
	Events.machine_task_ended.connect(build_on_change)
	print(machine_info.get_sidebar_tasks())
	task_selector.get_popup().id_pressed.connect(_task_menu_trigger)
	
	build()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MarginContainer/VBoxContainer/ProgressBar.value = task_timer.time_left


func _task_menu_trigger(id: int):
	machine_info.get_sidebar_task(id).start.call(machine_info)


func _add_task_option(task):
	task_selector.get_popup().add_item(task.title)


func build_on_change(new_machine_info: Machines.MachineInfo):
	if new_machine_info.get_id() != machine_info.get_id():
		return
	machine_info = new_machine_info
	build()


func build():
	set_progress_bar_maximum()
	set_machine_name()
	set_icon()
	set_tasks()


func set_machine_name():
	$MarginContainer/VBoxContainer/HBoxContainer/MachineName.text = \
		machine_info.get_machine_name()


func set_icon():
	$MarginContainer/VBoxContainer/HBoxContainer/MachineIcon.texture = \
		machine_info.get_icon()


func set_progress_bar_maximum():
	var time_cost = machine_info.get_task_time_cost()
	if time_cost == -1:
		progress_bar.hide()
	else:
		progress_bar.max_value = time_cost


func set_tasks():
	print("setting tasks", machine_info.get_sidebar_tasks())
	var tasks = machine_info.get_sidebar_tasks().map(_add_task_option)
