## Placement ghost: follows the mouse snapped to the tile grid, shows the
## footprint (green/red for valid/invalid) plus range/sensor/repair radius
## overlays, and instantiates the real building scene on a valid click.
## Validity for passive buildings goes through NavigationManager.
## validate_placement() so a wall that would seal off the Nexus is rejected
## before it's ever built.
class_name PlacementController
extends Node2D

signal building_placed(building: Node)

var _pending_data: DefenseBuildingData = null
var _origin_cell: Vector2i = Vector2i.ZERO
var _valid: bool = false


func is_active() -> bool:
	return _pending_data != null


func start_placement(data: DefenseBuildingData) -> void:
	if data.scene_path.is_empty():
		return
	_pending_data = data
	visible = true
	_update_from_mouse()


func cancel_placement() -> void:
	_pending_data = null
	visible = false
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _pending_data == null:
		return
	if event is InputEventMouseMotion:
		_update_from_mouse()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and _valid:
			_commit_placement()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_placement()


func _update_from_mouse() -> void:
	_origin_cell = NavigationManager.world_to_cell(get_global_mouse_position())
	var top_left: Vector2 = Vector2(_origin_cell) * NavigationManager.cell_size
	global_position = top_left + Vector2(_pending_data.footprint_size) * NavigationManager.cell_size * 0.5
	_validate()
	queue_redraw()


func _footprint_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(_pending_data.footprint_size.x):
		for y in range(_pending_data.footprint_size.y):
			cells.append(_origin_cell + Vector2i(x, y))
	return cells


func _validate() -> void:
	var cells: Array[Vector2i] = _footprint_cells()
	var passive_data: PassiveDefenseData = _pending_data as PassiveDefenseData
	if passive_data != null and not passive_data.passability_rules.is_empty():
		_valid = NavigationManager.validate_placement(cells, passive_data.passability_rules, _get_spawn_cells(), _get_nexus_cell())
	else:
		_valid = NavigationManager.can_place(cells)


func _get_nexus_cell() -> Vector2i:
	var nexus_nodes: Array = get_tree().get_nodes_in_group(DefenseEnums.GROUP_NEXUS)
	if nexus_nodes.is_empty():
		return Vector2i.ZERO
	return NavigationManager.world_to_cell(nexus_nodes[0].global_position)


func _get_spawn_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for marker in get_tree().get_nodes_in_group("enemy_spawn_points"):
		cells.append(NavigationManager.world_to_cell(marker.global_position))
	return cells


func _commit_placement() -> void:
	var scene: PackedScene = load(_pending_data.scene_path)
	if scene == null:
		return
	var instance: Node2D = scene.instantiate()
	instance.data = _pending_data
	instance.origin_cell = _origin_cell
	instance.global_position = global_position
	get_tree().current_scene.add_child(instance)
	building_placed.emit(instance)
	cancel_placement()


func _draw() -> void:
	if _pending_data == null:
		return
	var size: Vector2 = Vector2(_pending_data.footprint_size) * NavigationManager.cell_size
	var rect := Rect2(-size / 2.0, size)
	draw_rect(rect, Color(0.2, 0.9, 0.2, 0.35) if _valid else Color(0.9, 0.2, 0.2, 0.35))

	var weapon_data: WeaponData = _pending_data as WeaponData
	if weapon_data != null:
		draw_arc(Vector2.ZERO, weapon_data.range, 0.0, TAU, 64, Color(1.0, 1.0, 0.2, 0.6), 2.0)
		if weapon_data.min_range > 0.0:
			draw_arc(Vector2.ZERO, weapon_data.min_range, 0.0, TAU, 64, Color(1.0, 0.5, 0.0, 0.6), 2.0)
		return

	var sensor_data: SensorData = _pending_data as SensorData
	if sensor_data != null:
		draw_arc(Vector2.ZERO, sensor_data.sensor_range, 0.0, TAU, 64, Color(0.2, 0.9, 0.9, 0.6), 2.0)
		return

	var support_data: SupportData = _pending_data as SupportData
	if support_data != null:
		draw_arc(Vector2.ZERO, support_data.repair_radius, 0.0, TAU, 64, Color(0.2, 0.9, 0.5, 0.6), 2.0)
