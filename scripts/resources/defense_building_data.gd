## Base data schema shared by every defense building. Adding a new building
## later means adding one of these (or a subclass) as a .tres file under
## res://data/defense/ - BuildingRegistry picks it up automatically.
class_name DefenseBuildingData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var category: DefenseEnums.Category = DefenseEnums.Category.PASSIVE
@export var subcategory: DefenseEnums.Subcategory = DefenseEnums.Subcategory.BARRIERS
@export_multiline var description: String = ""

## resource_id (String) -> amount (int)
@export var build_cost: Dictionary = {}
@export var build_time: float = 1.0
@export var footprint_size: Vector2i = Vector2i.ONE

@export var max_health: int = 0
@export var armor: float = 0.0
## DefenseEnums.DamageType (int, as String key for Inspector-friendliness) -> resistance 0..1
@export var resistances: Dictionary = {}

@export var power_idle_draw: float = 0.0
@export var power_active_draw: float = 0.0
@export var maintenance_cost: float = 0.0

@export var required_ammo_type: String = ""
@export var required_research_tier: int = 0

@export var repairable: bool = true
@export var allowed_terrain_types: Array[String] = []
@export var destructible: bool = true

@export var upgradable: bool = false
@export var upgrade_target_id: String = ""

## Scene to instantiate when this building is placed. Empty for stubs that
## are data-only and not yet placeable.
@export_file("*.tscn") var scene_path: String = ""


func get_resistance(damage_type: DefenseEnums.DamageType) -> float:
	return resistances.get(damage_type, 0.0)
