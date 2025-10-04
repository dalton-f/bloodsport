extends Node

@onready var pause_menu = $CanvasLayer/PauseMenu

func _ready():
	pause_menu.resume_pressed.connect(resume_game)
	pause_menu.quit_pressed.connect(func(): get_tree().quit())

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	get_tree().paused = true
	pause_menu.visible = true
	Engine.time_scale = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume_game():
	get_tree().paused = false
	pause_menu.visible = false
	Engine.time_scale = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
