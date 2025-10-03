extends CharacterBody3D

var speed
var speed_mult = 1
var default_weapon_holder_position : Vector3
var tween: Tween

var active_effects = []

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

const HEADBOB_FREQUENCY = 2
const HEADBOB_AMPLITUDE = 0.04
var headbob_time = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var weapon_manager = $Head/Camera3D/WeaponsManager
@onready var center_label: Label = $CanvasLayer/UI/CenterContainer/Label
@onready var health_component = $HealthComponent
@onready var health_bar = $CanvasLayer/UI/MarginContainer/ProgressBar

func _ready():
	add_to_group("player")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_weapon_holder_position = weapon_manager.position
	
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.max_health
	
	health_component.connect("damage_taken", Callable(self, "_damage_effect"))
	health_component.connect("died", Callable(self, "_handle_death"))
	health_component.connect("health_changed", Callable(self, "_update_health_bar"))

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta):
	speed = WALK_SPEED * speed_mult
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED * speed_mult

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	headbob_time += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(headbob_time)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Shooting
	if Input.is_action_pressed("shoot"):
		weapon_manager.shoot()
	
	move_and_slide()
	
	_cam_tilt(input_dir.x, delta)
	_weapon_tilt(input_dir.x, delta)
	_weapon_bob(velocity.length(), delta)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * HEADBOB_FREQUENCY) * HEADBOB_AMPLITUDE
	pos.x = cos(time * HEADBOB_FREQUENCY / 2) * HEADBOB_AMPLITUDE
	return pos

func _cam_tilt(input_x, delta):
	if camera:
		camera.rotation.z = lerp(camera.rotation.z, -input_x * 0.02, 10 * delta)

func _weapon_tilt(input_x, delta):
	if weapon_manager:
		weapon_manager.rotation.z = lerp(weapon_manager.rotation.z, -input_x * 0.02 * 10, 10 * delta)

func _weapon_bob(vel : float, delta):
	if weapon_manager:
		if vel > 0 and is_on_floor():
			var bob_amount : float = 0.025
			var bob_freq : float = 0.01
			
			weapon_manager.position.y = lerp(weapon_manager.position.y, default_weapon_holder_position.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_manager.position.x = lerp(weapon_manager.position.x, default_weapon_holder_position.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
			
		else:
			weapon_manager.position.y = lerp(weapon_manager.position.y, default_weapon_holder_position.y, 10 * delta)
			weapon_manager.position.x = lerp(weapon_manager.position.x, default_weapon_holder_position.x, 10 * delta)

func apply_normal_pair(pair):
	pair["buff"]["apply"].call(self)
	pair["debuff"]["apply"].call(self)
	
	active_effects.append(pair)

func remove_normal_pair(pair):
	if pair in active_effects:
		pair["buff"]["revert"].call(self)
		pair["debuff"]["revert"].call(self)
		
		active_effects.erase(pair)

func apply_extreme(effect):
	effect["apply"].call(self)
	active_effects.append(effect)

func set_speed_multiplier(mult):
	speed_mult = mult

func show_wave_number(wave_index: int):
	center_label.text = "Wave %d" % (wave_index + 1)
	center_label.modulate.a = 0.0
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(center_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.2)                               
	tween.tween_property(center_label, "modulate:a", 0.0, 0.5)

func _update_health_bar(current_health):
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(health_bar, "value", current_health, 0.5)
	
func _handle_death():
	center_label.text = "You died!"
	center_label.modulate.a = 0.0
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(center_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.2)                               
	tween.tween_property(center_label, "modulate:a", 0.0, 0.5)

func _damage_effect(_amount):
	camera._camera_shake(0.2, 0.06)
