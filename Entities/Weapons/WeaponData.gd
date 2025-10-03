extends Resource
class_name WeaponData

@export var weapon_name: String = ""
@export var weapon_scene: PackedScene
@export var damage: int = 10;
@export var fire_rate: float = 3.5
@export var pellets: int = 1
@export var bullet_spread: float = 0
@export var range: int = 100
@export var sfx: AudioStream
