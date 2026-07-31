## Finds damaged buildings in radius and repairs them through the
## DefenseBuilding facade (request_repair) - never touches HealthComponent
## directly, so drones/other repair sources can reuse the same call later.
class_name RepairProviderComponent
extends Area2D

var repair_amount_per_tick: float = 5.0
var repair_material_cost_per_tick: float = 1.0
var max_simultaneous_targets: int = 1
var repair_priority: DefenseEnums.RepairPriorityMode = DefenseEnums.RepairPriorityMode.LOWEST_HEALTH_REMAINING

var _tick_timer: float = 0.0
const TICK_INTERVAL: float = 1.0


func setup(data: SupportData) -> void:
	repair_amount_per_tick = data.repair_amount_per_tick
	repair_material_cost_per_tick = data.repair_material_cost_per_tick
	max_simultaneous_targets = data.max_simultaneous_targets
	repair_priority = data.default_repair_priority

	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = DefenseEnums.LAYER_BUILDINGS

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = data.repair_radius
	shape.shape = circle
	add_child(shape)


func _process(delta: float) -> void:
	_tick_timer += delta
	if _tick_timer < TICK_INTERVAL:
		return
	_tick_timer = 0.0
	_repair_tick()


## get_overlapping_bodies() returns the buildings' stand-in PhysicsBody
## nodes (see DefenseBuilding._create_physics_body), not the buildings
## themselves - resolve back via the "owner_building" meta on each hit.
func _repair_tick() -> void:
	var candidates: Array = []
	for body in get_overlapping_bodies():
		if not is_instance_valid(body):
			continue
		var building: Node = body.get_meta("owner_building", null)
		if building == null or building == get_parent():
			continue
		if not building.is_in_group(DefenseEnums.GROUP_REPAIRABLE_BUILDINGS):
			continue
		if not building.has_method("is_repairable") or not building.is_repairable():
			continue
		if not building.has_method("get_health_percent") or building.get_health_percent() >= 1.0:
			continue
		candidates.append(building)
	if candidates.is_empty():
		return

	candidates.sort_custom(func(a, b): return _priority_key(a) < _priority_key(b))

	var count: int = min(max_simultaneous_targets, candidates.size())
	for i in range(count):
		candidates[i].request_repair(repair_amount_per_tick)


func _priority_key(building: Node) -> float:
	match repair_priority:
		DefenseEnums.RepairPriorityMode.NEXUS:
			return 0.0 if building.is_in_group(DefenseEnums.GROUP_NEXUS) else 1.0
		_:
			return building.get_health_percent()
