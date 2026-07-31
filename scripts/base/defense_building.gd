## Facade every cross-cutting system (repair, damage, UI) talks to. Builds
## its component set dynamically from which fields are set on `data` -
## never from branching on building id - so a new building only needs a
## new .tres, not new code, to get the right components.
class_name DefenseBuilding
extends Node2D

signal building_destroyed
signal health_changed(current: int, max_health: int)

@export var data: DefenseBuildingData

var health: HealthComponent = null
var armor: ArmorComponent = null
var status: StatusComponent
var physics_body: StaticBody2D = null

var origin_cell: Vector2i = Vector2i.ZERO


func _ready() -> void:
	status = StatusComponent.new()
	add_child(status)

	if data == null:
		push_warning("DefenseBuilding '%s' has no data assigned" % name)
		return

	if data.max_health > 0:
		health = HealthComponent.new()
		add_child(health)
		health.setup(data.max_health)
		health.health_changed.connect(_on_health_changed)
		health.died.connect(_on_died)

	if data.armor > 0.0 or not data.resistances.is_empty():
		armor = ArmorComponent.new()
		add_child(armor)
		armor.setup(data.armor, data.resistances)

	if data.repairable and health != null:
		add_to_group(DefenseEnums.GROUP_REPAIRABLE_BUILDINGS)

	_create_physics_body()
	NavigationManager.claim_cells(self, get_footprint_cells())


func _exit_tree() -> void:
	if data != null:
		NavigationManager.release_cells(get_footprint_cells())


## Every building (passive or active) occupies its footprint - this is
## spatial reservation only, separate from navigation passability (which
## only PassiveDefenseBuilding additionally applies via NavObstacleComponent).
func get_footprint_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if data == null:
		return cells
	for x in range(data.footprint_size.x):
		for y in range(data.footprint_size.y):
			cells.append(origin_cell + Vector2i(x, y))
	return cells


## Stand-in physical body so Area2D-based detection (repair radius, sensor/
## targeting line-of-sight) can find this building. DefenseBuilding itself
## is a plain Node2D, not a physics node, so callers that detect this body
## via get_overlapping_bodies() read the owning building back via
## get_meta("owner_building") rather than assuming the body IS the building.
func _create_physics_body() -> void:
	physics_body = StaticBody2D.new()
	physics_body.name = "PhysicsBody"
	physics_body.set_meta("owner_building", self)
	physics_body.collision_layer = DefenseEnums.LAYER_BUILDINGS
	physics_body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(data.footprint_size) * DefenseEnums.TILE_SIZE
	shape.shape = rect
	physics_body.add_child(shape)
	add_child(physics_body)


func take_damage(amount: float, damage_type: DefenseEnums.DamageType = DefenseEnums.DamageType.BALLISTIC, armor_penetration: float = 0.0, from_direction: Vector2 = Vector2.ZERO) -> void:
	if health == null or not data.destructible:
		return
	var mitigated: float = amount
	if armor != null:
		mitigated = armor.mitigate(amount, damage_type, armor_penetration, from_direction)
	health.apply_damage(mitigated)
	status.set_flag(DefenseEnums.BuildingStatus.DAMAGED, health.get_health_percent() < 1.0)


func request_repair(amount: float) -> void:
	if health == null or not is_repairable():
		return
	health.apply_repair(amount)
	status.set_flag(DefenseEnums.BuildingStatus.DAMAGED, health.get_health_percent() < 1.0)


func is_repairable() -> bool:
	return data != null and data.repairable and health != null and health.is_alive()


func get_health_percent() -> float:
	return health.get_health_percent() if health != null else 1.0


func is_alive() -> bool:
	return health == null or health.is_alive()


func get_status_flags() -> Array[String]:
	return status.get_active_flag_names()


## Generic hook for the info panel: subclasses/components can extend this
## by overriding _collect_extra_ui_fields() instead of the panel hardcoding
## per-building fields.
func get_ui_fields() -> Dictionary:
	var fields: Dictionary = {
		"display_name": data.display_name if data != null else name,
		"health": "%d / %d" % [health.current_health, health.max_health] if health != null else "-",
		"status": ", ".join(get_status_flags()),
	}
	fields.merge(_collect_extra_ui_fields())
	return fields


func _collect_extra_ui_fields() -> Dictionary:
	return {}


func _on_health_changed(current: int, max_health: int) -> void:
	health_changed.emit(current, max_health)


func _on_died() -> void:
	status.set_flag(DefenseEnums.BuildingStatus.DESTROYED, true)
	building_destroyed.emit()
