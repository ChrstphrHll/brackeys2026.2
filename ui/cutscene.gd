extends ColorRect

const FINAL_CUTSCENE = 2

enum CUTSCENES {
	OPENING,
	NO_ONE,
	ENDING
}

@export var selected_cutscene: CUTSCENES


@onready var timer = $Timer
var storyIndex = 0

var pictures = []

var textEntries = []


const OPENING_IMAGES = [
	preload("uid://c6awb0ifjubxf"),
	preload("uid://dykdf65mkmyql"),
	preload("res://assets/cutscene3.1.png"),
	preload("res://assets/Brackeys_Map.png"),
]

const OPENING_TEXT = [
	"Industry leaders in their greed force spirits into their machines for higher outputs.",
	"Furious with their imprisonment, the spirits broke free from their subjugation, bringing society to its knees.",
	"Returning from a scavenging trip, tragedy strikes and you are separated from your crew.",
	"Can you traverse through these wilds and make it back to your family in the city?"
]


const NO_ONE = [
	preload("uid://b8mbt430bm03b"),
	preload("uid://b03i007net8v3"),
	preload("uid://dj4hiwt2y8f1o"),
	preload("uid://dpbjrxtvc2d3x"),
	preload("uid://jw121l5c8rs4")
]

const NO_ONE_TEXT = [
	"A rustle from the bushes.",
	"An industrial arm pulls itself into the clearing moving with malice.",
	"Just as it moves to strike you, another shows up taking the hit instead.",
	"You quickly yank the battery from the arm safe from the original threat.",
	"You were saved by a machine, but can you trust them?",
]

const ENDING = [
	preload("res://assets/Ending.png"),
	preload("res://assets/credits.png")
]

const ENDING_TEXT = [
	"You return to the city to rejoicing neighbors",
	"A Game Jam Game by John, Charles, Christopher, and Adam."
]


func set_opening_cutscene():
	pictures = OPENING_IMAGES
	textEntries = OPENING_TEXT


func set_no_one_cutscene():
	pictures = NO_ONE
	textEntries = NO_ONE_TEXT


func set_ending_cutscene():
	pictures = ENDING
	textEntries = ENDING_TEXT


var cutscene_setters = [
	set_opening_cutscene,
	set_no_one_cutscene,
	set_ending_cutscene
]


func _ready():
	assert(len(textEntries) == len(pictures), "Pictures and Entries must be the same length")
	cutscene_setters[selected_cutscene].call()
	set_screen()


func _process(event):
	if Input.is_action_just_pressed("ui_accept"):
		if not progress_story():
			return
		set_screen()
		timer.start()


func _on_timer_timeout():
	if not progress_story():
		return
	set_screen()


func progress_story():
	storyIndex += 1
	if storyIndex == len(textEntries):
		if selected_cutscene == FINAL_CUTSCENE:
			Events.end_game()
		self.queue_free()
		return false
	return true


func set_screen():
	$Story.text = textEntries[storyIndex]
	$Image.texture = pictures[storyIndex]
