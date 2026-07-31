## Applies a passive building's passability rules to NavigationManager's
## grids and remembers exactly which cells/rules it wrote so it can revert
## precisely on removal - never guesses. Occupancy (spatial reservation) is
## a separate concern owned by DefenseBuilding itself, not this component -
## this only ever affects pathfinding, never blocks placement.
class_name NavObstacleComponent
extends Node

var _footprint_cells: Array[Vector2i] = []
var _applied_rules: Array[Dictionary] = []


func setup(footprint_cells: Array[Vector2i]) -> void:
	_footprint_cells = footprint_cells


func apply_rules(rules: Array[Dictionary]) -> void:
	revert()
	_applied_rules = rules
	NavigationManager.apply_obstacle(_footprint_cells, _applied_rules)


func revert() -> void:
	if _applied_rules.is_empty():
		return
	NavigationManager.clear_obstacle(_footprint_cells, _applied_rules)
	_applied_rules = []


func get_footprint_cells() -> Array[Vector2i]:
	return _footprint_cells


func _exit_tree() -> void:
	revert()
