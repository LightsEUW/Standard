## Data for turret/weapon buildings. WeaponComponent reads these fields to
## drive firing, targeting, ammo, and heat generically for every weapon.
class_name WeaponData
extends ActiveDefenseData

@export_group("Range & Aim")
@export var range: float = 300.0
@export var min_range: float = 0.0
@export var turret_rotation_speed: float = 180.0 # degrees/sec, 0 = instant
@export var target_acquisition_time: float = 0.0

@export_group("Fire")
@export var fire_rate: float = 1.0 # shots/sec
@export var projectile_speed: float = 600.0
@export var damage: float = 10.0
@export var damage_type: DefenseEnums.DamageType = DefenseEnums.DamageType.BALLISTIC
@export var splash_radius: float = 0.0
@export var armor_penetration: float = 0.0

@export_group("Ammo")
@export var ammo_capacity: int = 30
@export var reload_time: float = 2.0

@export_group("Power")
@export var idle_power_draw_override: float = -1.0 # -1 = use power_idle_draw
@export var firing_power_draw: float = 0.0

@export_group("Heat")
@export var heat_per_shot: float = 0.0 # 0 = weapon cannot overheat
@export var max_heat: float = 0.0
@export var cooldown_rate: float = 0.0

@export_group("Targeting")
@export var valid_target_types: Array[String] = ["ground"] # "ground" / "flying" / "projectile"
@export var default_target_priority: DefenseEnums.TargetPriorityMode = DefenseEnums.TargetPriorityMode.NEAREST
@export var requires_line_of_sight: bool = true
@export var requires_sensor_link: bool = false
@export var can_damage_own_buildings: bool = false
@export var is_indirect_fire: bool = false


func _init() -> void:
	super._init()
