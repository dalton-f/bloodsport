extends Area3D

@export var speed: float = 20
@export var lifetime: float = 5
@export var damage: int = 10

var velocity: Vector3 = Vector3.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	global_position += velocity * delta

	lifetime -= delta
	
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body):	
	if body.is_in_group("enemies"):
		return
		
	if body.is_in_group("player"):
		body.health_component.damage(damage)
		
	queue_free()
