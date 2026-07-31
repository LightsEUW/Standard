## Stub power grid. Grants power freely today, but exposes exactly the
## query/registration shape a real grid needs later to enforce the
## Nexus > active defense > distance-based-shutdown priority already fixed
## in docs/GAME_DESIGN.md - swapping the internals here is the only change
## required when that system is built; consumers never change.
extends Node

signal consumer_power_changed(building: Node, has_power: bool)

## debug_unlimited_power = true (default) means request_power always
## succeeds; toggle it off locally to rehearse brownout behavior before
## the real grid exists.
var debug_unlimited_power: bool = true

var _consumers: Dictionary = {} # Node -> {idle_draw, active_draw, is_active}


func register_consumer(building: Node, idle_draw: float, active_draw: float) -> void:
	_consumers[building] = {"idle_draw": idle_draw, "active_draw": active_draw, "is_active": false}


func unregister_consumer(building: Node) -> void:
	_consumers.erase(building)


func set_active(building: Node, active: bool) -> void:
	if _consumers.has(building):
		_consumers[building]["is_active"] = active


func request_power(building: Node) -> bool:
	var granted: bool = debug_unlimited_power
	consumer_power_changed.emit(building, granted)
	return granted


func get_total_draw() -> float:
	var total: float = 0.0
	for entry in _consumers.values():
		total += entry["active_draw"] if entry["is_active"] else entry["idle_draw"]
	return total


func get_registered_consumers() -> Array:
	return _consumers.keys()
