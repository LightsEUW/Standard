## Headless test entry point, no external test-framework dependency:
##   godot --headless --script res://tests/run_tests.gd
## Each case script (extends RefCounted) exposes run() -> Array[String] of
## failure messages; an empty array means the case passed. Covers pure-logic
## components only (health/armor/damage, ammo, status flags, target
## priority, navigation reachability) - physics-dependent behavior (range
## detection, line of sight, gate collision) needs the actual scene tree
## ticking and is left to manual verification in demo/defense_test_scene.tscn.
extends SceneTree

const TEST_SCRIPTS: Array[String] = [
	"res://tests/cases/test_health_component.gd",
	"res://tests/cases/test_armor_and_damage.gd",
	"res://tests/cases/test_ammo_component.gd",
	"res://tests/cases/test_status_component.gd",
	"res://tests/cases/test_target_priority.gd",
	"res://tests/cases/test_navigation_manager.gd",
]


func _initialize() -> void:
	var total_failures: int = 0
	for path in TEST_SCRIPTS:
		var script: GDScript = load(path)
		var test_case: RefCounted = script.new()
		var failures: Array = test_case.run()
		if failures.is_empty():
			print("PASS: %s" % path)
		else:
			for failure in failures:
				print("FAIL: %s - %s" % [path, failure])
			total_failures += failures.size()

	print("---")
	if total_failures == 0:
		print("ALL TESTS PASSED")
	else:
		print("%d FAILURE(S)" % total_failures)
	quit(1 if total_failures > 0 else 0)
