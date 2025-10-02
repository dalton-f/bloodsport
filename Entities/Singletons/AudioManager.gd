extends Node

# Music and SFX AudioStreamPlayers
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Volume controls
var music_volume: float = 0.6
var sfx_volume: float = 0.6

func _ready():
	# Create audio players dynamically
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"

	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"

# Play music
func play_music(track: AudioStream, loop: bool=true):
	music_player.stream = track
	music_player.loop = loop
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()

# Play sound effect
func play_sfx(effect: AudioStream):
	sfx_player.stream = effect
	sfx_player.volume_db = linear_to_db(sfx_volume)
	sfx_player.play()
