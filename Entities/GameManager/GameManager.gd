extends Node3D

@export var spawn_points: Array[NodePath] 
@export var player: CharacterBody3D

var waves = [
	{
		"enemies": [
			{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 3},
		],
	},
	{
		"enemies": [
			{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 5},
		],
	},
		{
		"enemies": [
			{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 10},
		],
	}
]
var current_wave := 0
var enemies_alive := 0

signal wave_started(wave_index)
signal wave_completed(wave_index)
signal all_waves_completed()

func _ready() -> void:
	start_waves()

func start_waves():
	current_wave = 0
	_start_wave()

func _start_wave():
	if current_wave >= waves.size():
		emit_signal("all_waves_completed")
		return

	var wave = waves[current_wave]
	emit_signal("wave_started", current_wave)
	
	player.show_wave_number(current_wave)

	spawn_wave(wave)

func spawn_wave(wave):
	for enemy_data in wave["enemies"]:
		for i in range(enemy_data["count"]):
			await get_tree().create_timer(1).timeout
			spawn_enemy(enemy_data["scene"])
			
func spawn_enemy(enemy_scene: PackedScene):
	var enemy = enemy_scene.instantiate()
	var spawn_point = get_node(spawn_points[randi() % spawn_points.size()])
	enemy.player = player

	add_child(enemy)
		
	enemy.global_transform.origin = spawn_point.global_transform.origin + Vector3(0, 0.5, 0)

	enemies_alive += 1
	enemy.health_component.connect("died", Callable(self, "_on_enemy_died"), CONNECT_ONE_SHOT)

func _on_enemy_died():
	enemies_alive -= 1
	
	if enemies_alive <= 0:
		emit_signal("wave_completed", current_wave)
		current_wave += 1
		_start_wave()
