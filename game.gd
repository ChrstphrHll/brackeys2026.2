extends Node



const machine_scene = preload("res://machines/machine.tscn")
var machines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_pressed():
	SceneManager.go_to("main_menu")


func _on_timer_timeout():
	print("timer done")


func add_new_machine():
	var instantiated_machine = machine_scene.instantiate()
	machines.push_back(instantiated_machine)
	add_child(instantiated_machine)


func _on_add_wood_pressed():
	add_new_machine()
	machines[0].start_resource_gathering_task("wood")
