extends Node

@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var win_menu = $CanvasLayer/WinMenu
@onready var wave_manager = $SubViewportContainer/SubViewport/World/WaveManager
@onready var player = $SubViewportContainer/SubViewport/World/Player

func _ready():
	pause_menu.resume_pressed.connect(resume_game)
	pause_menu.quit_pressed.connect(func(): get_tree().quit())
	
	wave_manager.connect("all_waves_completed", Callable(self, "handle_win"))
	win_menu.restart_pressed.connect(restart_game)
	win_menu.quit_pressed.connect(func(): get_tree().quit())
	
func _unhandled_input(event):
	if event.is_action_pressed("pause")  and not win_menu.visible:
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

func handle_win():
	win_menu.visible = true
	Engine.time_scale = 0
	get_tree().paused = true
	wave_manager.reset()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
	set_physics_process(false)

func restart_game():
	# Reset player health and position
	player.global_transform = Transform3D()
	player.health_component.heal(999)
	
	player.wave_display.visible = true
	player.enemies_remaining_display.visible = true
	player.health_bar.visible = true

	
	# Unpause game
	win_menu.visible = false
	Engine.time_scale = 1
	get_tree().paused = false
	set_physics_process(true)
	
	# Restart waves
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	wave_manager.start_waves()
