extends CharacterBody3D

var player = null

const SPEED = 2

const SEPARATION_RADIUS = 2.5
const SEPARATION_STRENGTH = 3

@onready var health_component = $HealthComponent
@onready var nav_agent = $NavigationAgent3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	health_component.connect("died", Callable(self, "_on_died"), CONNECT_ONE_SHOT)
	health_component.connect("health_changed", Callable(self, "_update_health_bar"))
	
	add_to_group("enemies")

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
	
	if player_dist < SEPARATION_RADIUS and player_dist > 2.5:
		player_separation = (global_position - player.global_position).normalized() * SEPARATION_STRENGTH * (SEPARATION_RADIUS - player_dist)

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player < 2.5:
		velocity.x = randf_range(-0.1, 0.1)
		velocity.z = randf_range(-0.1, 0.1)
	else:
		var move_dir = nav_dir * 1.0
		move_dir += separation * 0.5
		move_dir += player_separation * 0.7
		move_dir = move_dir.normalized()
		
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	
	move_and_slide()

	var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)

	if global_position.distance_to(look_target) > 0.01:
		look_at(look_target, Vector3.UP)
	
	move_and_slide()

func _on_died():
	queue_free()
