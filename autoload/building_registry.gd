## Scans res://data/defense recursively at startup and indexes every
## DefenseBuildingData by id/category/subcategory. Adding a new building
## (real or stub) is just adding a .tres file here - nothing re-registers
## it manually.
extends Node

const DATA_ROOT: String = "res://data/defense"

var _by_id: Dictionary = {}
var _by_subcategory: Dictionary = {}


func _ready() -> void:
	_by_id.clear()
	_by_subcategory.clear()
	_scan_directory(DATA_ROOT)


func get_by_id(id: String) -> DefenseBuildingData:
	return _by_id.get(id)


func get_all() -> Array:
	return _by_id.values()


func get_by_subcategory(subcategory: DefenseEnums.Subcategory) -> Array:
	return _by_subcategory.get(subcategory, [])


func get_by_category(category: DefenseEnums.Category) -> Array:
	return _by_id.values().filter(func(d): return d.category == category)


func _scan_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("BuildingRegistry: could not open %s" % path)
		return
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var full_path: String = path.path_join(entry)
		if dir.current_is_dir():
			_scan_directory(full_path)
		elif entry.ends_with(".tres"):
			_register_file(full_path)
		entry = dir.get_next()
	dir.list_dir_end()


func _register_file(path: String) -> void:
	var resource := ResourceLoader.load(path)
	if not (resource is DefenseBuildingData):
		push_warning("BuildingRegistry: %s is not a DefenseBuildingData" % path)
		return
	var building_data: DefenseBuildingData = resource
	if building_data.id.is_empty():
		push_warning("BuildingRegistry: %s has no id set" % path)
		return
	if _by_id.has(building_data.id):
		push_warning("BuildingRegistry: duplicate id '%s' (%s)" % [building_data.id, path])
	_by_id[building_data.id] = building_data
	if not _by_subcategory.has(building_data.subcategory):
		_by_subcategory[building_data.subcategory] = []
	_by_subcategory[building_data.subcategory].append(building_data)
