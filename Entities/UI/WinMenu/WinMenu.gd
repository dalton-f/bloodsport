extends Control

signal restart_pressed
signal quit_pressed

func _ready():
	%Restart.pressed.connect(func(): emit_signal("restart_pressed"))
	%Quit.pressed.connect(func(): emit_signal("quit_pressed"))
