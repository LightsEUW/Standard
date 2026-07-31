## Assumes autoloads are available under `godot --headless --script ...`
## (Godot initializes project autoloads independently of which MainLoop
## script runs) - if your Godot build behaves otherwise, run this test
## from within a running scene instead.
extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	NavigationManager.configure(Vector2i(10, 10), Vector2(64, 64))

	var open_path: PackedVector2Array = NavigationManager.find_path(DefenseEnums.PROFILE_GROUND_LARGE, Vector2i(0, 0), Vector2i(9, 9))
	if open_path.is_empty():
		failures.append("a path should exist on an empty grid")

	var wall_cells: Array[Vector2i] = []
	for y in range(10):
		wall_cells.append(Vector2i(5, y))
	var solid_rule: Array[Dictionary] = [{"profile": DefenseEnums.PROFILE_GROUND_LARGE, "solid": true, "weight_scale": 1.0}]
	NavigationManager.apply_obstacle(wall_cells, solid_rule)

	var blocked_path: PackedVector2Array = NavigationManager.find_path(DefenseEnums.PROFILE_GROUND_LARGE, Vector2i(0, 0), Vector2i(9, 9))
	if not blocked_path.is_empty():
		failures.append("a full-column wall should block the path on the profile it was applied to")

	NavigationManager.clear_obstacle(wall_cells, solid_rule)
	var reopened_path: PackedVector2Array = NavigationManager.find_path(DefenseEnums.PROFILE_GROUND_LARGE, Vector2i(0, 0), Vector2i(9, 9))
	if reopened_path.is_empty():
		failures.append("clearing the obstacle should reopen the path")

	var weight_cells: Array[Vector2i] = [Vector2i(3, 3)]
	var weight_rule: Array[Dictionary] = [{"profile": DefenseEnums.PROFILE_GROUND_SMALL, "solid": false, "weight_scale": 9.0}]
	NavigationManager.apply_obstacle(weight_cells, weight_rule)
	var weighted_path: PackedVector2Array = NavigationManager.find_path(DefenseEnums.PROFILE_GROUND_SMALL, Vector2i(0, 0), Vector2i(9, 9))
	if weighted_path.is_empty():
		failures.append("a weight-only rule should never fully block a path")
	if not is_equal_approx(NavigationManager.get_weight_scale(Vector2i(3, 3), DefenseEnums.PROFILE_GROUND_SMALL), 9.0):
		failures.append("get_weight_scale should reflect the applied weight_scale")

	var flying_path: PackedVector2Array = NavigationManager.find_path(DefenseEnums.PROFILE_FLYING, Vector2i(0, 0), Vector2i(9, 9))
	if flying_path.is_empty():
		failures.append("the flying profile should ignore ground-only obstacles entirely")

	NavigationManager.clear_obstacle(weight_cells, weight_rule)

	# Occupancy is a separate concern from navigation passability - every
	# building (active or passive) reserves its cells regardless of whether
	# it affects pathfinding at all.
	var reserved_cells: Array[Vector2i] = [Vector2i(2, 2), Vector2i(2, 3)]
	if not NavigationManager.can_place(reserved_cells):
		failures.append("an empty area should be placeable before anything claims it")
	NavigationManager.claim_cells(null, reserved_cells)
	if NavigationManager.can_place(reserved_cells):
		failures.append("can_place should reject cells already claimed by another building")
	if NavigationManager.can_place([Vector2i(2, 3), Vector2i(2, 4)]):
		failures.append("can_place should reject a footprint that partially overlaps a claimed cell")
	NavigationManager.release_cells(reserved_cells)
	if not NavigationManager.can_place(reserved_cells):
		failures.append("releasing cells should make them placeable again")

	if NavigationManager.can_place([Vector2i(-1, 0)]):
		failures.append("can_place should reject out-of-bounds cells")

	return failures
