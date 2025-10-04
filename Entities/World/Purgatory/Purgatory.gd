extends Node3D

@onready var pair_display = $Pair
@onready var extreme_display = $Extreme

func _ready():
	randomize()
	
	var chosen_pair = EffectsManager.pairs.pick_random()
	var chosen_extreme = EffectsManager.extremes.pick_random()
	
	pair_display.text = chosen_pair["buff"]["name"] + " / " +  chosen_pair["debuff"]["name"]
	extreme_display.text = chosen_extreme["name"]
