extends Node



const machine_scene = preload("res://machines/machine.tscn")
@onready var machines = [$UI/Machines/Machine]

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.machine_added.connect(_on_machine_added)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_pressed():
	SceneManager.go_to("main_menu")


func _on_machine_added(machine: Machine):
	$UI/Machines.add_child(machine)


func add_new_machine():
	var test_machine = Machine.new()
	machines.push_back(test_machine)
