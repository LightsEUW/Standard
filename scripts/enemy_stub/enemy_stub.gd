## Minimal test dummy - explicitly NOT a wave/AI system. Implements just the
## "defense_targets" duck-typed contract (is_alive/get_target_type/
## take_damage/global_position + the optional get_health/get_armor/
## get_speed/get_path_progress used by richer TargetPriority modes) so
## weapons/sensors have something real to detect during manual testing.
## Walks a precomputed AStarGrid2D path toward the "nexus" group node,
## reading NavigationManager's per-cell weight_scale for slowdown.
class_name EnemyStub
extends CharacterBody2D

var data: EnemyStubData
var health: HealthComponent

var _waypoints: PackedVector2Array = []
var _waypoint_index: int = 0
var _target_type: String = "ground"


func setup(p_data: EnemyStubData) -> void:
	data = p_data


func _ready() -> void:
	add_to_group(DefenseEnums.GROUP_DEFENSE_TARGETS)
	collision_layer = DefenseEnums.LAYER_DEFENSE_TARGETS
	collision_mask = 0

	health = HealthComponent.new()
	add_child(health)
	if data != null:
		health.setup(data.max_health)
		_target_type = "flying" if data.is_flying else "ground"
	health.died.connect(_on_died)

	_setup_collision()
	_setup_visual()
	_compute_path()


func _physics_process(_delta: float) -> void:
	if data == null or _waypoints.is_empty() or _waypoint_index >= _waypoints.size():
		velocity = Vector2.ZERO
		return
	var target_point: Vector2 = _waypoints[_waypoint_index]
	var current_cell: Vector2i = NavigationManager.world_to_cell(global_position)
	var weight_scale: float = NavigationManager.get_weight_scale(current_cell, data.movement_profile)
	var effective_speed: float = data.speed / max(1.0, weight_scale)
	velocity = global_position.direction_to(target_point) * effective_speed
	move_and_slide()
	if global_position.distance_to(target_point) < 6.0:
		_waypoint_index += 1


func _compute_path() -> void:
	if data == null:
		return
	var nexus_nodes: Array = get_tree().get_nodes_in_group(DefenseEnums.GROUP_NEXUS)
	if nexus_nodes.is_empty():
		return
	var origin_cell: Vector2i = NavigationManager.world_to_cell(global_position)
	var nexus_cell: Vector2i = NavigationManager.world_to_cell(nexus_nodes[0].global_position)
	_waypoints = NavigationManager.find_path(data.movement_profile, origin_cell, nexus_cell)
	_waypoint_index = 0


func is_alive() -> bool:
	return health != null and health.is_alive()


func get_target_type() -> String:
	return _target_type


func take_damage(amount: float, damage_type: DefenseEnums.DamageType = DefenseEnums.DamageType.BALLISTIC, armor_penetration: float = 0.0) -> void:
	if health == null:
		return
	var mitigated: float = DamageCalculator.calculate(amount, data.armor if data != null else 0.0, 0.0, armor_penetration)
	health.apply_damage(mitigated)


func get_health() -> float:
	return health.current_health if health != null else 0.0


func get_max_health() -> float:
	return health.max_health if health != null else 0.0


func get_armor() -> float:
	return data.armor if data != null else 0.0


func get_speed() -> float:
	return data.speed if data != null else 0.0


func get_path_progress() -> float:
	if _waypoints.is_empty():
		return 0.0
	return float(_waypoint_index) / float(_waypoints.size())


func _on_died() -> void:
	queue_free()


func _setup_collision() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	add_child(shape)


func _setup_visual() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(20.0, 20.0)
	rect.position = Vector2(-10.0, -10.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color(0.2, 0.5, 0.9) if (data != null and data.is_flying) else Color(0.8, 0.2, 0.2)
	add_child(rect)
