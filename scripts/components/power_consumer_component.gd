## Registers a building with the PowerGridService autoload and exposes
## whether it currently has power. The service is a swappable boundary -
## today it grants power freely, later it can enforce the Nexus > active
## defense > distance-based brownout priority from docs/GAME_DESIGN.md
## without this component changing at all.
class_name PowerConsumerComponent
extends Node

signal power_state_changed(has_power: bool)

var idle_draw: float = 0.0
var active_draw: float = 0.0
var has_power: bool = true
var _building: Node = null


func setup(building: Node, p_idle_draw: float, p_active_draw: float) -> void:
	_building = building
	idle_draw = p_idle_draw
	active_draw = p_active_draw
	PowerGridService.register_consumer(_building, idle_draw, active_draw)


func _exit_tree() -> void:
	if _building != null:
		PowerGridService.unregister_consumer(_building)


func set_active(active: bool) -> void:
	PowerGridService.set_active(_building, active)


func poll_power() -> bool:
	var granted: bool = PowerGridService.request_power(_building)
	if granted != has_power:
		has_power = granted
		power_state_changed.emit(has_power)
	return has_power
