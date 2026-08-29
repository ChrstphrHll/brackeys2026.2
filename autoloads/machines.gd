extends Node

const machine_scene = preload("res://machines/machine.tscn")


var machines = [MachineInfo.new(
	"You",
	preload("res://icon.svg"),
)]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func add_new_machine(name: String, icon: Resource, speed: int, efficiency: int, tasks: Array):
	var test_machine = MachineInfo.new(
		name,
		icon,
		speed,
		efficiency,
		tasks
	)
	print(tasks)
	machines.append(test_machine)
	Events.add_machine(test_machine)

class MachineInfo extends Node:
	var _id: int
	var _machine_name: String
	var _icon: Resource
	var _speed: int
	var _efficiency: int
	var _tasks = []
	var _current_task: String
	var _task_timer = Timer.new()
	var _current_task_time_cost: int = -1
	
	
	func _init(machine_name, icon, speed = 1, efficiency = 10, tasks = []):
		_id = ResourceUID.create_id()
		ResourceUID.add_id(_id, "machine_ids")
		_machine_name = machine_name
		_icon = icon
		_speed = speed
		_efficiency = efficiency
		_tasks = tasks
		add_child(_task_timer)
		get_tree().add_child(self)
	
	
	func get_id() -> int:
		return _id
	
	
	func get_machine_name() -> String:
		return _machine_name
	
	
	func get_icon() -> Resource:
		return _icon


	func get_speed() -> int:
		return _speed
		
	
	func get_efficiency() -> int:
		return _efficiency


	func get_task_time_cost() -> int:
		return _current_task_time_cost
	
	
	func getSideBarView() -> Machine:
		var instantiated_machine = machine_scene.instantiate()
		instantiated_machine.machine_info = self
		return instantiated_machine
	
	
	func get_sidebar_tasks():
		return _tasks.filter(Tasks.is_sidebar_task)


	func get_sidebar_task(id: int):
		var sidebar_tasks = get_sidebar_tasks()
		return sidebar_tasks[id]


	func implement_consequence(task_name):
		pass


	func start_task(task_name: String, time_cost: int, bound_callback: Callable):
		_current_task = task_name
		_task_timer.timeout.connect(bound_callback)
		Events.start_machine_task(self)
		
		_task_timer.start(time_cost)
		await get_tree().create_timer(time_cost).timeout
		print("waited")


	func end_task(bound_callback):
		implement_consequence(_current_task)
		_task_timer.timeout.disconnect(bound_callback)
		_current_task = ""
		_current_task_time_cost = -1
		Events.end_machine_task(self)
