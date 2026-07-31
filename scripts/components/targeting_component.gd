## Range detection (Area2D) + line-of-sight + sensor-link gating + priority
## selection for a WeaponBuilding. Only ever talks to the generic
## "defense_targets" group contract (is_alive/get_target_type/take_damage/
## global_position, see EnemyStub) - it has no idea what a "gegner" is
## beyond that, so any future real enemy AI slots in unmodified.
class_name TargetingComponent
extends Area2D

var valid_target_types: Array[String] = ["ground"]
var target_priority: DefenseEnums.TargetPriorityMode = DefenseEnums.TargetPriorityMode.NEAREST
var requires_line_of_sight: bool = true
var requires_sensor_link: bool = false
var min_range: float = 0.0

var current_target: Node = null

var _owner_building: Node2D = null


func setup(owner_building: Node2D, data: WeaponData) -> void:
	_owner_building = owner_building
	valid_target_types = data.valid_target_types
	target_priority = data.default_target_priority
	requires_line_of_sight = data.requires_line_of_sight
	requires_sensor_link = data.requires_sensor_link
	min_range = data.min_range

	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = DefenseEnums.LAYER_DEFENSE_TARGETS

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = data.range
	shape.shape = circle
	add_child(shape)


func refresh_target() -> Node:
	var candidates: Array = _gather_candidates()
	if candidates.is_empty():
		current_target = null
		return null
	current_target = TargetPriority.pick_target(candidates, target_priority, global_position)
	return current_target


func _gather_candidates() -> Array:
	if requires_sensor_link:
		return _gather_from_sensor_network()
	return _filter(get_overlapping_bodies())


func _gather_from_sensor_network() -> Array:
	# Sensor-linked weapons (e.g. mortar, artillery) don't scan on their own;
	# they trust whatever the sensor network has already detected, still
	# re-run the shared filter for target-type/LOS/min-range/liveness.
	return _filter(SensorNetwork.get_all_detected_targets())


func _filter(candidates: Array) -> Array:
	var result: Array = []
	for candidate in candidates:
		if not is_instance_valid(candidate):
			continue
		if not candidate.is_in_group(DefenseEnums.GROUP_DEFENSE_TARGETS):
			continue
		if not candidate.has_method("is_alive") or not candidate.is_alive():
			continue
		var target_type: String = candidate.get_target_type() if candidate.has_method("get_target_type") else "ground"
		if not valid_target_types.has(target_type):
			continue
		var distance: float = global_position.distance_to(candidate.global_position)
		if distance < min_range:
			continue
		if requires_line_of_sight and not _has_line_of_sight(candidate):
			continue
		result.append(candidate)
	return result


## Only checks against LAYER_SIGHT_BLOCKER (currently-solid passive
## buildings) - any hit means something blocks the view; no hit means clear,
## regardless of whether the ray happens to reach the candidate exactly.
func _has_line_of_sight(candidate: Node) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, candidate.global_position)
	query.collision_mask = DefenseEnums.LAYER_SIGHT_BLOCKER
	var result := space_state.intersect_ray(query)
	return result.is_empty()
