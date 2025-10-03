extends Node

var pairs = [
	{
		"buff": {"name": "Speed Boost", "apply": func(p): p.set_speed_multiplier(1.5), "revert": func(p): p.set_speed_multiplier(1.0)},
		"debuff": {"name": "Damage Down", "apply": func(p): p.weapon_manager.set_damage_mult(0.5), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
	},
	
	{
		"buff": {"name": "Long Range", "apply": func(p): p.weapon_manager.set_range_mult(2), "revert": func(p): p.weapon_manager.set_range_mult(1)},
		"debuff": {"name": "Slow Down", "apply": func(p): p.set_speed_multiplier(0.75), "revert": func(p): p.set_speed_multiplier(1)},
	},
]

var extremes = [
	{"name": "Insane Damage!", "apply": func(p): p.weapon_manager.set_damage_mult(5), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
	{"name": "Totally Broken Slow", "apply": func(p): p.movement.set_speed_multiplier(0.25), "revert": func(p): p.movement.set_speed_multiplier(1.0)}
]
