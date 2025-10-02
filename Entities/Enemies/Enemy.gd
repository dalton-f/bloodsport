extends CharacterBody3D

var player = null

const SPEED = 4.0

@export var player_path : NodePath

@onready var navigation_agent = $NavigationAgent3D
@onready var health_component = $HealthComponent

func _ready():
	player = get_node(player_path)
	
	health_component.connect("died", Callable(self, "_on_died"))

func _process(_delta):
	velocity = Vector3.ZERO
	
	# Navigation
	navigation_agent.set_target_position(player.global_transform.origin)
	var next_navigation_point = navigation_agent.get_next_path_position()
	velocity = (next_navigation_point - global_transform.origin).normalized() * SPEED
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()

func _on_died():
	queue_free()
