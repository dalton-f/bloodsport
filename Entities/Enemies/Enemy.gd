extends CharacterBody3D

var player = null

const SPEED = 2

@export var player_path : NodePath

@onready var navigation_agent = $NavigationAgent3D
@onready var health_component = $HealthComponent
@onready var health_bar = $SubViewport/Panel/ProgressBar

func _ready():
	player = get_node(player_path)
	
	health_bar.max_value = health_component.max_health
	
	health_component.connect("died", Callable(self, "_on_died"))
	health_component.connect("health_changed", Callable(self, "_update_health_bar"))

func _process(_delta):
	velocity = Vector3.ZERO
	
	# Navigation
	navigation_agent.set_target_position(player.global_transform.origin)
	var next_navigation_point = navigation_agent.get_next_path_position()
	velocity = (next_navigation_point - global_position).normalized() * SPEED
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()

func _on_died():
	queue_free()

func _update_health_bar(current_health):
	create_tween().tween_property(health_bar, "value", current_health, 0.5)
