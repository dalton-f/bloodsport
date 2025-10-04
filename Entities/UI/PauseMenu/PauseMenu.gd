extends Control

signal resume_pressed
signal quit_pressed

func _ready():
	%Resume.pressed.connect(func(): emit_signal("resume_pressed"))
	%Quit.pressed.connect(func(): emit_signal("quit_pressed"))
