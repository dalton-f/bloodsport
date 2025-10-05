extends Node3D

@onready var pair_display = $Pair/PairLabel
@onready var extreme_display = $Extreme/ExtremeLabel
@onready var extreme_area = $Extreme/ExtremeArea3D
@onready var normal_area = $Pair/NormalArea

var chosen_pair
var chosen_extreme
var player

func _ready():
	normal_area.body_entered.connect(_on_normal_chosen)
	extreme_area.body_entered.connect(_on_extreme_chosen)
	
	player =  get_parent().get_node("Player")

func randomize_effects():
	randomize()
		
	chosen_pair = EffectsManager.pairs.pick_random()
	chosen_extreme = EffectsManager.extremes.pick_random()
	
	pair_display.text = chosen_pair["buff"]["name"] + " / " + chosen_pair["debuff"]["name"]

func _on_normal_chosen(body):
	if not body.is_in_group("player"):
		return
	
	player.apply_normal_pair(chosen_pair)
	restart_game()

func _on_extreme_chosen(body):
	if not body.is_in_group("player"):
		return
	
	player.apply_extreme(chosen_extreme)
	restart_game()
	
func restart_game():
	var root = get_tree().current_scene
	root.restart_game()
	visible = false
