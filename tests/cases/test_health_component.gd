extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []

	var health := HealthComponent.new()
	health.setup(100)
	if health.current_health != 100:
		failures.append("setup() should initialize current_health to max_health")

	health.apply_damage(30.0)
	if health.current_health != 70:
		failures.append("apply_damage(30) should leave 70 hp, got %d" % health.current_health)

	health.apply_repair(10.0)
	if health.current_health != 80:
		failures.append("apply_repair(10) should leave 80 hp, got %d" % health.current_health)

	health.apply_repair(1000.0)
	if health.current_health != 100:
		failures.append("apply_repair should clamp to max_health, got %d" % health.current_health)

	var died_signal_fired := false
	health.died.connect(func(): died_signal_fired = true)
	health.apply_damage(1000.0)
	if health.current_health != 0:
		failures.append("apply_damage should clamp at 0, got %d" % health.current_health)
	if not died_signal_fired:
		failures.append("died signal should fire when health reaches 0")
	if health.is_alive():
		failures.append("is_alive() should be false at 0 hp")

	return failures
