## Owns one named AStarGrid2D per movement profile (ground_small,
## ground_large, flying) plus a cell-occupancy map. Passability differences
## between building types come entirely from the PassabilityRule data they
## pass in - this manager never branches on building identity, which is
## what lets a trench (blocks small, open for large) and a spike field
## (never solid, just costly) coexist without special-case code.
extends Node

var map_size_in_cells: Vector2i = Vector2i(64, 64)
var cell_size: Vector2 = Vector2(64, 64)

var profiles: Dictionary = {} # String -> AStarGrid2D
var occupancy: Dictionary = {} # Vector2i -> Node (or null while dry-running)


func _ready() -> void:
	_rebuild_profiles()


## Called once by the map/demo scene after it knows the real grid size.
func configure(p_map_size_in_cells: Vector2i, p_cell_size: Vector2) -> void:
	map_size_in_cells = p_map_size_in_cells
	cell_size = p_cell_size
	_rebuild_profiles()
	occupancy.clear()


func _rebuild_profiles() -> void:
	profiles.clear()
	for profile_name in DefenseEnums.ALL_PROFILES:
		var grid := AStarGrid2D.new()
		grid.region = Rect2i(Vector2i.ZERO, map_size_in_cells)
		grid.cell_size = cell_size
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		grid.update()
		profiles[profile_name] = grid


func can_place(footprint_cells: Array[Vector2i]) -> bool:
	for cell in footprint_cells:
		if not _in_bounds(cell) or occupancy.has(cell):
			return false
	return true


## Pure dry-run: applies the rules, checks every spawn cell can still reach
## the Nexus on the most permissive ground profile, then always reverts.
## Callers (placement UI) should only instantiate the building if this
## returns true. Occupancy is checked but not claimed here - claiming
## happens once the real building enters the tree (DefenseBuilding._ready).
func validate_placement(footprint_cells: Array[Vector2i], rules: Array[Dictionary], spawn_cells: Array[Vector2i], nexus_cell: Vector2i) -> bool:
	if not can_place(footprint_cells):
		return false
	apply_obstacle(footprint_cells, rules)
	var reachable: bool = true
	for spawn_cell in spawn_cells:
		if find_path(DefenseEnums.PROFILE_GROUND_LARGE, spawn_cell, nexus_cell).is_empty():
			reachable = false
			break
	clear_obstacle(footprint_cells, rules)
	return reachable


## Navigation-rule application only - does NOT touch occupancy. Every
## building (passive or active) claims its footprint via claim_cells() once
## in DefenseBuilding._ready(); only passive buildings additionally call
## this to affect pathfinding.
func apply_obstacle(footprint_cells: Array[Vector2i], rules: Array[Dictionary]) -> void:
	for rule in rules:
		var grid: AStarGrid2D = profiles.get(rule.get("profile", ""))
		if grid == null:
			continue
		for cell in footprint_cells:
			if not grid.is_in_boundsv(cell):
				continue
			grid.set_point_solid(cell, rule.get("solid", false))
			grid.set_point_weight_scale(cell, max(0.01, float(rule.get("weight_scale", 1.0))))


func clear_obstacle(footprint_cells: Array[Vector2i], rules: Array[Dictionary]) -> void:
	for rule in rules:
		var grid: AStarGrid2D = profiles.get(rule.get("profile", ""))
		if grid == null:
			continue
		for cell in footprint_cells:
			if not grid.is_in_boundsv(cell):
				continue
			grid.set_point_solid(cell, false)
			grid.set_point_weight_scale(cell, 1.0)


func claim_cells(building: Node, footprint_cells: Array[Vector2i]) -> void:
	for cell in footprint_cells:
		occupancy[cell] = building


func release_cells(footprint_cells: Array[Vector2i]) -> void:
	for cell in footprint_cells:
		occupancy.erase(cell)


func get_weight_scale(cell: Vector2i, profile: String) -> float:
	var grid: AStarGrid2D = profiles.get(profile)
	if grid == null or not grid.is_in_boundsv(cell):
		return 1.0
	return grid.get_point_weight_scale(cell)


func find_path(profile: String, from_cell: Vector2i, to_cell: Vector2i) -> PackedVector2Array:
	var grid: AStarGrid2D = profiles.get(profile)
	if grid == null or not grid.is_in_boundsv(from_cell) or not grid.is_in_boundsv(to_cell):
		return PackedVector2Array()
	return grid.get_point_path(from_cell, to_cell)


func world_to_cell(world_position: Vector2) -> Vector2i:
	return Vector2i(floor(world_position.x / cell_size.x), floor(world_position.y / cell_size.y))


func cell_to_world_center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * cell_size + cell_size * 0.5


func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_size_in_cells.x and cell.y < map_size_in_cells.y
