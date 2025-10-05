extends CharacterBody3D

@export var damage_sfx = AudioStream

var speed
var speed_mult = 1
var default_weapon_holder_position : Vector3
var health_tween: Tween
var center_tween: Tween

var active_effects = []

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5.2
const SENSITIVITY = 0.004
const CROUCH_SPEED = 3.0
const CROUCH_HEIGHT = 1.0
const STAND_HEIGHT = 2.0 

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
@onready var wave_display = $CanvasLayer/UI/MarginContainer2/WaveNum
@onready var enemies_remaining_display = $CanvasLayer/UI/MarginContainer2/RemainingNum
@onready var active_effect_display = $MarginContainer2/ActiveEffect

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

	# Handle Crouch
	if Input.is_action_pressed("crouch"):
		speed = CROUCH_SPEED * speed_mult
		scale.y = lerp(scale.y, 0.5, delta * 10)
	else:
		scale.y = lerp(scale.y, 1.0, delta * 10)
				
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
	
	active_effect_display.text = "ACTIVE EFFECT: " + pair["buff"]["name"] + " / " + pair["debuff"]["name"]

func apply_extreme(effect):
	effect["apply"].call(self)
	active_effects.append(effect)
	
	active_effect_display.text = "ACTIVE EFFECT: " + effect["name"]

func remove_all_effects():
	for effect in active_effects.duplicate():
		if "buff" in effect and "debuff" in effect:
			effect["buff"]["revert"].call(self)
			effect["debuff"]["revert"].call(self)
		elif "revert" in effect:
			effect["revert"].call(self)
		
		active_effects.erase(effect)
		
	active_effect_display.text = "ACTIVE EFFECTS: NONE"

func set_speed_multiplier(mult):
	speed_mult = mult

func show_wave_number(wave_index: int):
	if center_tween and center_tween.is_running():
		center_tween.kill()
	
	center_label.text = "WAVE %d" % (wave_index + 1)
	center_label.modulate.a = 0.0
	
	center_tween = create_tween()
	center_tween.tween_property(center_label, "modulate:a", 1.0, 0.5)
	center_tween.tween_interval(0.2)                               
	center_tween.tween_property(center_label, "modulate:a", 0.0, 0.5)
	
	wave_display.text = "WAVE %d" % (wave_index + 1)

func show_enemies_number(enemies: int):
	enemies_remaining_display.text = "REMAINING %d" % enemies

func _update_health_bar(current_health):
	if health_tween and health_tween.is_running():
		health_tween.kill()
		
	health_tween = create_tween()
	health_tween.tween_property(health_bar, "value", current_health, 0.5)
	
func _handle_death():
	health_bar.value = 0
	
	var wave_manager = get_parent().get_node("WaveManager")
	wave_manager.reset()
			
	set_physics_process(false)
	
	center_label.text = "YOU DIED"
	center_label.modulate.a = 0.0
	
	if center_tween and center_tween.is_running():
		center_tween.kill()
	
	center_tween = create_tween()
	center_tween.tween_property(center_label, "modulate:a", 1.0, 0.5)
	center_tween.tween_interval(0.85)                               
	center_tween.tween_property(center_label, "modulate:a", 0.0, 0.75)

	camera._camera_shake(0.5, 0.05)
	
	wave_display.visible = false
	enemies_remaining_display.visible = false
	health_bar.visible = false
	
	enemies_remaining_display.text = "REMAINING ??"
	wave_display.text = "WAVE 1"
	
	await center_tween.finished
	_teleport_to_purgatory()

func _teleport_to_purgatory():
	remove_all_effects()
	
	set_physics_process(true)
		
	var root = get_parent()
	
	var purgatory = root.get_node("Purgatory")
	var purgatory_spawn = purgatory.get_node("PurgatorySpawn")
	purgatory.visible = true
	purgatory.randomize_effects()
		
	global_position = purgatory_spawn.global_position

	health_component.heal(999)	
	
	center_label.text = "PICK AN EFFECT FOR YOUR NEXT RUN"
	center_label.modulate.a = 0.0
	
	if center_tween and center_tween.is_running():
		center_tween.kill()
	
	center_tween = create_tween()
	center_tween.tween_property(center_label, "modulate:a", 1.0, 0.5)
	center_tween.tween_interval(1)                               
	center_tween.tween_property(center_label, "modulate:a", 0.0, 0.5)
	
func _damage_effect(_amount):
	camera._camera_shake(0.2, 0.02)
	AudioManager.play_sfx(damage_sfx)
