extends Node3D

@export var spawn_points: Array[NodePath] 
@export var player: CharacterBody3D
@export var spawn_sfx: AudioStream


var waves = [
	{
		"enemies": [
			{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 3},
		],
	},
	#{
		#"enemies": [
			#{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 5},
		#],
	#},
		#{
		#"enemies": [
			#{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 7},
		#],
	#},
		#{
		#"enemies": [
			#{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 7},
		#],
	#},
			#{
		#"enemies": [
			#{"scene": preload("res://Entities/Enemies/Enemy.tscn"), "count": 7},
		#],
	#}
]

var current_wave := 0
var enemies_alive := 0
var spawned_enemies: Array = []

signal wave_started(wave_index)
signal wave_completed(wave_index)
signal all_waves_completed()

func _ready() -> void:
	start_waves()

func reset():
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()

	current_wave = 0
	enemies_alive = 0

func start_waves():	
	reset()
	_start_wave()

func _start_wave():
	if current_wave >= waves.size():
		emit_signal("all_waves_completed")
		return

	var wave = waves[current_wave]
	emit_signal("wave_started", current_wave)
	
	player.show_wave_number(current_wave)
	await get_tree().create_timer(1,5).timeout

	spawn_wave(wave)

func spawn_wave(wave):
	for enemy_data in wave["enemies"]:
		for i in range(enemy_data["count"]):
			await get_tree().create_timer(1).timeout
			spawn_enemy(enemy_data["scene"])
			
func spawn_enemy(enemy_scene: PackedScene):
	var enemy = enemy_scene.instantiate()
	var spawn_point = get_node(spawn_points.pick_random())
	enemy.player = player

	add_child(enemy)
		
	enemy.global_transform.origin = spawn_point.global_transform.origin + Vector3(0, 1, 0)

	enemies_alive += 1
	enemy.health_component.connect("died", Callable(self, "_on_enemy_died"), CONNECT_ONE_SHOT)

	# Temporarily disable the enemy’s collision shape when spawning
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	await get_tree().create_timer(0.2).timeout
	enemy.collision_layer = 1
	enemy.collision_mask = 1

	AudioManager.play_sfx(spawn_sfx)
	
	player.show_enemies_number(enemies_alive)
	spawned_enemies.append(enemy)
	
func _on_enemy_died():
	enemies_alive -= 1
	
	player.show_enemies_number(enemies_alive)
	
	if enemies_alive <= 0:
		emit_signal("wave_completed", current_wave)
		current_wave += 1
		_start_wave()
