extends Control

class_name Machine

@export var machine_name: String
var currentTask

var speed = 10
var efficiency = 10
var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = machine_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_resource_gathering_task(resource: String):
	timer = Timer.new()
	timer.wait_time = 1# get_task_time(speed, resource)
	var result = get_gathering_result(efficiency, resource)
	timer.timeout.connect(_on_gather_timeout.bind(resource, result))
	timer.start()
	print("hypothetically started timer")


func _on_gather_timeout(resource, delta: int):
	print("timeout")
	Resources.modify_resource(resource, delta)
	implement_consequence()

func get_task_time(speed, resource):
	return speed * Resources.get_resource_difficulty(resource)
	

func get_gathering_result(efficiency, resource):
	return efficiency * Resources.get_resource_abundance(resource)


func implement_consequence():
	pass
