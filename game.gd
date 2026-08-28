extends Node


const machine_scene = preload("res://machines/machine.tscn")
@onready var machines = [$UI/Machines/Machine]

@onready var tech_tree_button: Button = $UI/TechTreeButton
@onready var tech_tree_menu = $UI/TechTreeMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	tech_tree_button.pressed.connect(
		tech_tree_menu.open_menu
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_pressed():
	SceneManager.go_to("main_menu")


func add_new_machine():
	var test_machine = Machine.new()
	machines.push_back(test_machine)


func _on_add_wood_pressed():
	add_new_machine()
	machines[0].start_resource_gathering_task("wood")
