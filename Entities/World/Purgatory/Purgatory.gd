extends Node3D

@onready var pair_display = $Pair/PairLabel
@onready var extreme_display = $Extreme

func _ready():
	randomize()
	
	var chosen_pair = EffectsManager.pairs.pick_random()
	var chosen_extreme = EffectsManager.extremes.pick_random()
	
	pair_display.text = chosen_pair["buff"]["name"] + " / " +  chosen_pair["debuff"]["name"]
	extreme_display.text = chosen_extreme["name"]

	
func restart_game():
	var root = get_tree().current_scene
	root.restart_game()
