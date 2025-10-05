extends Node

var pairs = [
	{
		"buff": {"name": "SPEED BOOST", "apply": func(p): p.set_speed_multiplier(1.5), "revert": func(p): p.set_speed_multiplier(1.0)},
		"debuff": {"name": "DAMAGE DOWN", "apply": func(p): p.weapon_manager.set_damage_mult(0.5), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
	},
	
	{
		"buff": {"name": "LONG RANGE", "apply": func(p): p.weapon_manager.set_range_mult(2), "revert": func(p): p.weapon_manager.set_range_mult(1)},
		"debuff": {"name": "SLOW DOWN", "apply": func(p): p.set_speed_multiplier(0.5), "revert": func(p): p.set_speed_multiplier(1)},
	},
	
	{
		"buff": {"name": "MORE DAMAGE", "apply": func(p): p.weapon_manager.set_damage_mult(1.5), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
		"debuff": {"name": "RANGE DOWN", "apply": func(p): p.weapon_manager.set_range_mult(0.75), "revert": func(p): p.weapon_manager.set_range_mult(1)},
	},
	
	{
		"buff": {"name": "QUICK ATTACKER", "apply": func(p): p.weapon_manager.set_attack_speed_mult(2), "revert": func(p): p.weapon_manager.set_attack_speed_mult(1)},
		"debuff": {"name": "CLOSE RANGE ONLY", "apply": func(p): p.weapon_manager.set_range_mult(0.5), "revert": func(p): p.weapon_manager.set_range_mult(1)},
	},
	
	{
		"buff": {"name": "MORE DAMAGE", "apply": func(p): p.weapon_manager.set_damage_mult(1.5), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
		"debuff": {"name": "SLOW DOWN", "apply": func(p): p.set_speed_multiplier(0.5), "revert": func(p): p.set_speed_multiplier(1)},
	},

]

var extremes = [
	{"name": "INSANE DAMAGE", "apply": func(p): p.weapon_manager.set_damage_mult(3), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
	{"name": "TOTALLY BROKEN SLOW", "apply": func(p): p.set_speed_multiplier(0.25), "revert": func(p): p.set_speed_multiplier(1.0)},
	{"name": "LOOONGER RANGE", "apply": func(p): p.weapon_manager.set_range_mult(3), "revert": func(p): p.weapon_manager.set_range_mult(1)},
	{"name": "QUICKEST ATTACKER", "apply": func(p): p.weapon_manager.set_attack_speed_mult(3), "revert": func(p): p.weapon_manager.set_attack_speed_mult(1)},
	{"name": "SLOWEST ATTACKER", "apply": func(p): p.weapon_manager.set_attack_speed_mult(0.5), "revert": func(p): p.weapon_manager.set_attack_speed_mult(1)},
	{"name": "SHORTEST RANGE", "apply": func(p): p.weapon_manager.set_range_mult(0.5), "revert": func(p): p.weapon_manager.set_range_mult(1)},
	{"name": "FANTASTICALY FAST", "apply": func(p): p.set_speed_multiplier(3), "revert": func(p): p.set_speed_multiplier(1.0)},
	{"name": "AWFUL DAMAGE", "apply": func(p): p.weapon_manager.set_damage_mult(0.3), "revert": func(p): p.weapon_manager.set_damage_mult(1)},
]
