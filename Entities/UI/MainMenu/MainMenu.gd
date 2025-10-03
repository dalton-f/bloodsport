extends Control
@export var music: AudioStream

# Access the play and exit buttons by using their unique names (need to be toggled in the node tree)
func _ready():
	AudioManager.play_music(music)
	
	%Play.pressed.connect(play)
	%Quit.pressed.connect(exit)

# Load the main game scene after it has been loaded
func play():
	var target = load("res://Entities/World/World.tscn")
	
	get_tree().change_scene_to_packed(target)

# Quits the game	
func exit():
	get_tree().quit()
