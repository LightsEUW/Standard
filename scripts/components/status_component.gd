## Bitmask of DefenseEnums.BuildingStatus flags. Multiple flags can be active
## at once (e.g. DAMAGED + NO_POWER simultaneously) - not every flag applies
## to every building, callers just set what's relevant to them.
class_name StatusComponent
extends Node

signal status_changed(flags: int)

var _flags: int = DefenseEnums.BuildingStatus.ACTIVE


func set_flag(flag: DefenseEnums.BuildingStatus, enabled: bool) -> void:
	var before: int = _flags
	if enabled:
		_flags |= flag
	else:
		_flags &= ~flag
	if _flags != before:
		status_changed.emit(_flags)


func has_flag(flag: DefenseEnums.BuildingStatus) -> bool:
	return (_flags & flag) != 0


func get_flags() -> int:
	return _flags


func get_active_flag_names() -> Array[String]:
	var names: Array[String] = []
	for flag_name in DefenseEnums.BuildingStatus.keys():
		var flag_value: int = DefenseEnums.BuildingStatus[flag_name]
		if has_flag(flag_value):
			names.append(flag_name)
	return names
