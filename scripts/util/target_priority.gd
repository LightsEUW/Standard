## Static target selection over a fixed, small, design-owned taxonomy
## (DefenseEnums.TargetPriorityMode). This is the one place allowed to
## switch on a category - it never switches on building/enemy identity.
## Candidates only need to satisfy the "defense_targets" duck-typed
## contract (see EnemyStub): is_alive, get_target_type, global_position,
## and the optional get_health/get_armor/get_speed/get_path_progress used
## by the richer priority modes (missing methods fall back to 0).
class_name TargetPriority
extends RefCounted


static func pick_target(candidates: Array, mode: DefenseEnums.TargetPriorityMode, origin: Vector2) -> Node:
	var alive: Array = candidates.filter(func(c): return is_instance_valid(c) and c.is_alive())
	if alive.is_empty():
		return null

	match mode:
		DefenseEnums.TargetPriorityMode.NEAREST:
			return _closest(alive, origin, false)
		DefenseEnums.TargetPriorityMode.FASTEST:
			return _extreme(alive, func(c): return _call_or(c, "get_speed", 0.0), true)
		DefenseEnums.TargetPriorityMode.STRONGEST:
			return _extreme(alive, func(c): return _call_or(c, "get_health", 0.0), true)
		DefenseEnums.TargetPriorityMode.WEAKEST:
			return _extreme(alive, func(c): return _call_or(c, "get_health", 0.0), false)
		DefenseEnums.TargetPriorityMode.MOST_HEALTH:
			return _extreme(alive, func(c): return _call_or(c, "get_health", 0.0), true)
		DefenseEnums.TargetPriorityMode.MOST_ARMOR:
			return _extreme(alive, func(c): return _call_or(c, "get_armor", 0.0), true)
		DefenseEnums.TargetPriorityMode.FIRST_ON_PATH:
			return _extreme(alive, func(c): return _call_or(c, "get_path_progress", 0.0), true)
		DefenseEnums.TargetPriorityMode.LAST_ON_PATH:
			return _extreme(alive, func(c): return _call_or(c, "get_path_progress", 0.0), false)
		DefenseEnums.TargetPriorityMode.FLYING_ONLY:
			var flying: Array = alive.filter(func(c): return _call_or(c, "get_target_type", "ground") == "flying")
			return _closest(flying, origin, false) if not flying.is_empty() else null
		_:
			return _closest(alive, origin, false)


static func _closest(candidates: Array, origin: Vector2, farthest: bool) -> Node:
	return _extreme(candidates, func(c): return origin.distance_squared_to(c.global_position), not farthest)


static func _extreme(candidates: Array, value_fn: Callable, want_min: bool) -> Node:
	if candidates.is_empty():
		return null
	var best: Node = candidates[0]
	var best_value: float = value_fn.call(best)
	for i in range(1, candidates.size()):
		var value: float = value_fn.call(candidates[i])
		if (want_min and value < best_value) or (not want_min and value > best_value):
			best = candidates[i]
			best_value = value
	return best


static func _call_or(node: Node, method: String, default_value):
	if node.has_method(method):
		return node.call(method)
	return default_value
