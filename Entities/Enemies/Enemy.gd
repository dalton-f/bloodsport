extends CharacterBody3D

var player = null

const SPEED = 2

const SEPARATION_RADIUS = 2.5
const SEPARATION_STRENGTH = 3

const SHOOTING_RANGE = 10
const SHOOT_COOLDOWN = 0.75

@onready var health_component = $HealthComponent
@onready var nav_agent = $NavigationAgent3D
@onready var damage_indicator = $DamageIndicator
@onready var spawn_particles = $GPUParticles3D

@export var ProjectileScene: PackedScene 

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var shoot_timer = 0.0

func _ready():
	health_component.connect("died", Callable(self, "_on_died"), CONNECT_ONE_SHOT)
	health_component.connect("damage_taken", Callable(self, "_on_damage_taken"))
	
	add_to_group("enemies")
	
	spawn_particles.emitting = true
	spawn_particles.connect("finished", Callable(spawn_particles, "queue_free"))

func _process(delta):
	velocity = Vector3.ZERO
		
	if not is_on_floor():
		velocity.y -= gravity * delta

	var target_pos = player.global_position

	nav_agent.set_target_position(target_pos)
	
	var next_nav_point = nav_agent.get_next_path_position()
	var nav_dir = (next_nav_point - global_position).normalized()
	
	var separation = Vector3.ZERO

	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self:
			continue
			
		var diff = global_position - other.global_position
		var dist = diff.length()
		
		if dist < randf_range(2.5, 4) and dist > 0.01:
			separation += diff.normalized() * SEPARATION_STRENGTH * (SEPARATION_RADIUS - dist)
		
	var player_separation = Vector3.ZERO
	var player_dist = global_position.distance_to(player.global_position)
	
	shoot_timer -= delta
	
	if player_dist < SEPARATION_RADIUS and player_dist > 2.5:
		player_separation = (global_position - player.global_position).normalized() * SEPARATION_STRENGTH * (SEPARATION_RADIUS - player_dist)

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player < SHOOTING_RANGE:
		velocity.x = randf_range(-0.1, 0.1)
		velocity.z = randf_range(-0.1, 0.1)
		
		if shoot_timer <= 0.0:
			shoot_timer = SHOOT_COOLDOWN
			shoot_projectile()
	else:
		var move_dir = nav_dir * 1.0
		move_dir += separation * 0.5
		move_dir += player_separation * 0.7
		move_dir = move_dir.normalized()
		
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED

	var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)

	if global_position.distance_to(look_target) > 0.01:
		look_at(look_target, Vector3.UP)
	
	move_and_slide()

func _on_died():
	queue_free()

func shoot_projectile():
	if player == null:
		return

	var projectile = ProjectileScene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var spawn_position = global_transform.origin + Vector3.UP * 0.5
	projectile.global_transform.origin = spawn_position

	var player_pos = player.global_transform.origin
	var player_vel = player.velocity
	
	# Predict player position
	var to_player = player_pos - spawn_position
	var travel_time = to_player.length() / projectile.speed
	var future_pos = player_pos + player_vel * travel_time
	
	var aim_error = Vector3(
		randf_range(-1.5, 1.5),
		randf_range(-0.5, 0.5), 
		randf_range(-1.5, 1.5)
	)
	
	future_pos += aim_error

	var direction = (future_pos - spawn_position).normalized()
	projectile.velocity = direction * projectile.speed

func _on_damage_taken(amount: float) -> void:
	damage_indicator.create_indicator_label(-amount)
