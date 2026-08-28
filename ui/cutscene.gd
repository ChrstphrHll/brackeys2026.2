extends ColorRect

@onready var timer = $Timer
var storyIndex = 0

var pictures = [
	preload("res://assets/WoodResource.png"),
	preload("res://assets/Bulldozer.png"),
	preload("res://icon.svg")
]

var textEntries = [
	"this is the first part of the story",
	"this is the second",
	"and finally, thjis quite long thing hereand finally, thjis quite long thing hereand finally, thjis quite long thing hereand finally, thjis quite long thing here."
]



func _ready():
	assert(len(textEntries) == len(pictures), "Pictures and Entries must be the same length")
	
	set_screen()


func _on_timer_timeout():
	storyIndex += 1
	print(len(textEntries), storyIndex, storyIndex == len(textEntries))
	if storyIndex == len(textEntries):
		self.queue_free()
		return
	
	set_screen()


func set_screen():
	$Story.text = textEntries[storyIndex]
	$Image.texture = pictures[storyIndex]
