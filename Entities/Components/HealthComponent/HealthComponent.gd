extends Node3D
class_name HealthComponent

@export_category("Health Variables")
@export var max_health: int = 100

@export_category("Regeneration Variables")
@export var regeneration_enabled: bool = true
# How much health per second gets regenerated
@export var natural_regeneration_rate: int = 5
# Seconds after damage before regeneration restarts
@export var regeneration_delay: int = 3

var current_health: float

var _regeneration_timer: float = 0.0
var _can_regenerate: bool = true

signal health_changed(new_health: int)
signal died

func _ready() -> void:
	current_health = max_health
	
	_regeneration_timer = regeneration_delay
	
	emit_signal("health_changed", current_health)

func _process(delta: float) -> void:
	if not regeneration_enabled:
		return
		
	if has_died():
		return
		
	if _can_regenerate and current_health < max_health:
		current_health = min(current_health + natural_regeneration_rate * delta, max_health)
		emit_signal("health_changed", current_health)
		return
		

	# Count timer down if player has just taken damage (ie. _can_regenerate is false)
	_regeneration_timer = max(_regeneration_timer - delta, 0.0)
	
	if _regeneration_timer <= 0.0:
		_can_regenerate = true
		
func damage(amount: int) -> void:
	current_health = current_health - amount
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		emit_signal("died")
		
	# Reset regeneration delay timer after taking damage
	_can_regenerate = false
	_regeneration_timer = regeneration_delay

func heal(amount: int) -> void:
	print("healing from ", current_health, " up to ", current_health + amount)
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health)

func has_died() -> bool:
	return current_health <= 0
