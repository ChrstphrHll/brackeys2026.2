extends CenterContainer

@onready var play_button = $PlayButton



func _on_play_button_pressed():
	SceneManager.go_to("game")
