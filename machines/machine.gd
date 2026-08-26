extends Control

class_name Machine

@export var machine_name: String = "test"
var currentTask

var speed = 10
var efficiency = 10
@onready var task_timer: Timer = $TaskTimer
@onready var test = $MarginContainer/VBoxContainer/HBoxContainer/MenuButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MarginContainer/VBoxContainer/ProgressBar.value = task_timer.time_left


func start_resource_gathering_task(resource: String):
	task_timer.start()
	print("hypothetically started timer")


func get_task_time(speed, resource):
	return speed * Resources.get_resource_difficulty(resource)
	

func get_gathering_result(efficiency, resource):
	return efficiency * Resources.get_resource_abundance(resource)


func implement_consequence():
	pass


func _on_button_pressed():
	start_resource_gathering_task("wood")

func _on_task_timer_timeout():
	Resources.modify_resource("wood", 100)
	implement_consequence()


func _on_menu_button_button_down():
	print('menu button down')
	pass # Replace with function body.
