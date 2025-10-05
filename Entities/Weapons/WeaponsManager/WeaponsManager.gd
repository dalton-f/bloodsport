@tool
extends Node3D

@export var weapon_data: WeaponData

var camera
var damage_mult = 1
var range_mult = 1
var attack_speed_mult = 1

var current_weapon: Node3D
var can_shoot: bool = true

var muzzle_flash = preload("res://Entities/Weapons/MuzzleFlash.tscn")

func _ready():
	current_weapon = weapon_data.weapon_scene.instantiate()
	add_child(current_weapon)
	
	camera = get_parent()

func shoot():
	if get_tree().paused:
		return
		
	if not can_shoot or current_weapon == null or camera == null:
		return
		
	can_shoot = false
	
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	
	for i in range(weapon_data.pellets):
		var origin = camera.project_ray_origin(screen_center)
		
		var direction = camera.project_ray_normal(screen_center)
		
		direction.x += randf_range(-weapon_data.bullet_spread, weapon_data.bullet_spread)
		direction.y += randf_range(-weapon_data.bullet_spread, weapon_data.bullet_spread)
		direction = direction.normalized()
		
		# Project a ray normal from the center of the screen up to a distance of 100
		var end = origin + direction * (weapon_data.weapon_range * range_mult)
	
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		
		if result and result.collider.has_node("HealthComponent"):
			result.collider.get_node("HealthComponent").damage(weapon_data.damage * damage_mult)
	
	_spawn_muzzle_flash()
	current_weapon.apply_recoil()
	
	AudioManager.play_sfx(weapon_data.sfx)
	
	camera._camera_shake(0.2, 0.025)
	
	var cooldown = 1.0 / (float(weapon_data.fire_rate) * attack_speed_mult)
	await get_tree().create_timer(cooldown).timeout
	can_shoot = true

func _spawn_muzzle_flash():
	var muzzle_point = current_weapon.get_node_or_null("MuzzlePoint")
	
	if muzzle_point:
		var flash = muzzle_flash.instantiate()
		muzzle_point.add_child(flash)
		flash.global_transform = muzzle_point.global_transform
		flash.emitting = true
		
		# Auto-remove after animation/short delay
		await get_tree().create_timer(0.1).timeout
		if flash and flash.is_inside_tree():
			flash.queue_free()

func set_damage_mult(mult):
	damage_mult = mult

func set_range_mult(mult):
	range_mult = mult
