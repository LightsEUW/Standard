## Detects targets in range and registers them with the SensorNetwork
## autoload so sensor-linked weapons (mortar, artillery, ...) can query
## without hardcoding which watchtower/radar feeds them.
class_name SensorComponent
extends Area2D

var detects_flying: bool = true
var requires_line_of_sight: bool = true


func setup(data: SensorData) -> void:
	detects_flying = data.detects_flying
	requires_line_of_sight = data.requires_line_of_sight

	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = DefenseEnums.LAYER_DEFENSE_TARGETS

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = data.sensor_range
	shape.shape = circle
	add_child(shape)

	if data.feeds_targeting_network:
		SensorNetwork.register_sensor(self)


func _exit_tree() -> void:
	SensorNetwork.unregister_sensor(self)


func get_detected_targets() -> Array:
	var result: Array = []
	for body in get_overlapping_bodies():
		if not is_instance_valid(body) or not body.is_in_group(DefenseEnums.GROUP_DEFENSE_TARGETS):
			continue
		if not body.has_method("is_alive") or not body.is_alive():
			continue
		var target_type: String = body.get_target_type() if body.has_method("get_target_type") else "ground"
		if target_type == "flying" and not detects_flying:
			continue
		if requires_line_of_sight and not _has_line_of_sight(body):
			continue
		result.append(body)
	return result


func _has_line_of_sight(target: Node) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.collision_mask = DefenseEnums.LAYER_SIGHT_BLOCKER
	var result := space_state.intersect_ray(query)
	return result.is_empty()
