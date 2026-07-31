extends RefCounted

const MockTargetScript := preload("res://tests/mock_target.gd")


func _make_mock(position: Vector2, health: float = 10.0, target_type: String = "ground") -> Node2D:
	var mock: Node2D = MockTargetScript.new()
	mock.position = position
	mock.health = health
	mock.target_type = target_type
	return mock


func run() -> Array[String]:
	var failures: Array[String] = []

	var near: Node2D = _make_mock(Vector2(10, 0), 20.0)
	var far: Node2D = _make_mock(Vector2(500, 0), 20.0)
	var strong: Node2D = _make_mock(Vector2(100, 0), 90.0)
	var candidates: Array = [near, far, strong]

	var nearest := TargetPriority.pick_target(candidates, DefenseEnums.TargetPriorityMode.NEAREST, Vector2.ZERO)
	if nearest != near:
		failures.append("NEAREST should pick the closest candidate")

	var strongest := TargetPriority.pick_target(candidates, DefenseEnums.TargetPriorityMode.STRONGEST, Vector2.ZERO)
	if strongest != strong:
		failures.append("STRONGEST should pick the highest-health candidate")

	var dead: Node2D = _make_mock(Vector2(5, 0), 20.0)
	dead.alive = false
	var with_dead: Array = [dead, far]
	var picked := TargetPriority.pick_target(with_dead, DefenseEnums.TargetPriorityMode.NEAREST, Vector2.ZERO)
	if picked != far:
		failures.append("dead candidates should be excluded from selection")

	var flying: Node2D = _make_mock(Vector2(50, 0), 10.0, "flying")
	var ground: Node2D = _make_mock(Vector2(5, 0), 10.0, "ground")
	var flying_only := TargetPriority.pick_target([flying, ground], DefenseEnums.TargetPriorityMode.FLYING_ONLY, Vector2.ZERO)
	if flying_only != flying:
		failures.append("FLYING_ONLY should never pick a ground target")

	var empty_result := TargetPriority.pick_target([], DefenseEnums.TargetPriorityMode.NEAREST, Vector2.ZERO)
	if empty_result != null:
		failures.append("pick_target on an empty candidate list should return null")

	for mock in [near, far, strong, dead, flying, ground]:
		mock.free()

	return failures
