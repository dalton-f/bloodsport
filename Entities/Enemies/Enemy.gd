extends CharacterBody3D

var player = null
var tween : Tween

const SPEED = 3.5

const SEPARATION_RADIUS = 2.5
const SEPARATION_STRENGTH = 3

@onready var health_component = $HealthComponent
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
	var direction = target_pos - global_position
	var distance = direction.length()
	

	if distance > 2.5:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector3.ZERO
		
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self:
			continue
			
		var diff = global_position - other.global_position
		var dist = diff.length()
		
		if dist < SEPARATION_RADIUS and dist > 0.01:
			velocity += diff.normalized() * SEPARATION_STRENGTH * (SEPARATION_RADIUS - dist)

	if velocity.length() > SPEED:
		velocity = velocity.normalized() * SPEED
	
	var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)

	if global_position.distance_to(look_target) > 0.01:
		look_at(look_target, Vector3.UP)
	
	move_and_slide()

func _on_died():
	queue_free()
