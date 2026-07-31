## Heat buildup for weapons with max_heat > 0 (per WeaponData - a weapon
## with max_heat == 0 simply never gets one of these attached).
class_name HeatComponent
extends Node

signal overheated
signal cooled_down

var max_heat: float = 0.0
var cooldown_rate: float = 0.0
var current_heat: float = 0.0
var _is_overheated: bool = false


func setup(p_max_heat: float, p_cooldown_rate: float) -> void:
	max_heat = p_max_heat
	cooldown_rate = p_cooldown_rate


func is_overheated() -> bool:
	return _is_overheated


func add_heat(amount: float) -> void:
	current_heat = min(max_heat, current_heat + amount)
	if current_heat >= max_heat and not _is_overheated:
		_is_overheated = true
		overheated.emit()


func _process(delta: float) -> void:
	if current_heat <= 0.0:
		return
	current_heat = max(0.0, current_heat - cooldown_rate * delta)
	if _is_overheated and current_heat <= max_heat * 0.5:
		_is_overheated = false
		cooled_down.emit()
