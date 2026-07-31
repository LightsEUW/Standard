## Tracks hit points for a DefenseBuilding. Raw damage only - resistance
## mitigation happens in ArmorComponent/DamageCalculator before this is called.
class_name HealthComponent
extends Node

signal health_changed(current: int, max_health: int)
signal died

var current_health: int = 0
var max_health: int = 0


func setup(p_max_health: int) -> void:
	max_health = p_max_health
	current_health = p_max_health


func is_alive() -> bool:
	return current_health > 0


func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)


func apply_damage(amount: float) -> void:
	if not is_alive():
		return
	current_health = max(0, current_health - int(round(amount)))
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()


func apply_repair(amount: float) -> void:
	if max_health <= 0:
		return
	current_health = min(max_health, current_health + int(round(amount)))
	health_changed.emit(current_health, max_health)
