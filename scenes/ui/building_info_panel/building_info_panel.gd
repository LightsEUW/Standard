## Shows whichever fields the selected building's get_ui_fields() returns -
## never hardcodes per-building-type fields, so new buildings/components
## show up here automatically. Also owns the "click a building to select
## it" input, deferring to the placement controller while it's active.
class_name BuildingInfoPanel
extends PanelContainer

@export var placement_controller: PlacementController

var _selected: DefenseBuilding = null
var _list: VBoxContainer


func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(240.0, 0.0)
	_list = VBoxContainer.new()
	add_child(_list)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if placement_controller != null and placement_controller.is_active():
		return
	_try_select_at(get_global_mouse_position())


func _try_select_at(world_pos: Vector2) -> void:
	var space_state := get_viewport().world_2d.direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collision_mask = DefenseEnums.LAYER_BUILDINGS
	var results: Array = space_state.intersect_point(query, 1)
	if results.is_empty():
		clear()
		return
	var building: Node = results[0]["collider"].get_meta("owner_building", null)
	if building == null:
		clear()
		return
	show_building(building)


func show_building(building: DefenseBuilding) -> void:
	_selected = building
	visible = true
	_refresh()


func clear() -> void:
	_selected = null
	visible = false


func _process(_delta: float) -> void:
	if _selected == null:
		return
	if not is_instance_valid(_selected):
		clear()
		return
	_refresh()


func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()
	var fields: Dictionary = _selected.get_ui_fields()
	for field_key in fields.keys():
		var label := Label.new()
		label.text = "%s: %s" % [field_key, fields[field_key]]
		_list.add_child(label)
