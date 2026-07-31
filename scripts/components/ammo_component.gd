## Local ammo magazine + reload timer. Depletes on fire, and on hitting
## empty asks the SupplyService autoload for resupply - that call is the
## swap point for a future logistics system; the magazine model itself
## doesn't need to change when that arrives.
class_name AmmoComponent
extends Node

signal ammo_changed(current: int, capacity: int)
signal reload_started
signal reload_finished

var ammo_type: String = ""
var capacity: int = 0
var current_ammo: int = 0
var reload_time: float = 0.0

var _reloading: bool = false
var _reload_elapsed: float = 0.0


func setup(p_ammo_type: String, p_capacity: int, p_reload_time: float) -> void:
	ammo_type = p_ammo_type
	capacity = p_capacity
	current_ammo = p_capacity
	reload_time = p_reload_time


func is_empty() -> bool:
	return current_ammo <= 0


func is_reloading() -> bool:
	return _reloading


func try_consume(amount: int = 1) -> bool:
	if capacity <= 0:
		return true # weapon needs no ammo (e.g. energy weapons)
	if _reloading or current_ammo < amount:
		if not _reloading:
			_start_reload()
		return false
	current_ammo -= amount
	ammo_changed.emit(current_ammo, capacity)
	if current_ammo <= 0:
		_start_reload()
	return true


func _start_reload() -> void:
	if _reloading or capacity <= 0:
		return
	_reloading = true
	_reload_elapsed = 0.0
	reload_started.emit()
	SupplyService.request_resupply(self, ammo_type, capacity)


func _process(delta: float) -> void:
	if not _reloading:
		return
	_reload_elapsed += delta
	if _reload_elapsed >= reload_time:
		current_ammo = capacity
		_reloading = false
		ammo_changed.emit(current_ammo, capacity)
		reload_finished.emit()
