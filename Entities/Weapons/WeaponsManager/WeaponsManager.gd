@tool
extends Node3D

@export var weapon_data: WeaponData

var camera

var current_weapon: Node3D
var can_shoot: bool = true

func _ready():
	current_weapon = weapon_data.weapon_scene.instantiate()
	add_child(current_weapon)
	
	camera = get_parent()

func shoot():
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
		var end = origin + direction * 100.0
	
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		
		if result and result.collider.has_node("HealthComponent"):
			result.collider.get_node("HealthComponent").damage(weapon_data.damage)
	
	current_weapon.apply_recoil()
	
	var cooldown = 1.0 / float(weapon_data.fire_rate)
	await get_tree().create_timer(cooldown).timeout
	can_shoot = true
