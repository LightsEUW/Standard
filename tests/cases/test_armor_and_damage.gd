extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []

	# armor flatly reduces damage before resistance is applied
	var mitigated: float = DamageCalculator.calculate(50.0, 10.0, 0.0, 0.0)
	if not is_equal_approx(mitigated, 40.0):
		failures.append("expected 40 after 10 flat armor, got %f" % mitigated)

	# armor_penetration reduces effective armor
	mitigated = DamageCalculator.calculate(50.0, 10.0, 0.0, 6.0)
	if not is_equal_approx(mitigated, 46.0):
		failures.append("expected 46 with 6 armor penetration against 10 armor, got %f" % mitigated)

	# resistance is a percentage of what's left after armor
	mitigated = DamageCalculator.calculate(100.0, 0.0, 0.5, 0.0)
	if not is_equal_approx(mitigated, 50.0):
		failures.append("expected 50 with 0.5 resistance, got %f" % mitigated)

	# damage never goes negative
	mitigated = DamageCalculator.calculate(5.0, 100.0, 0.0, 0.0)
	if mitigated < 0.0:
		failures.append("damage should never be negative, got %f" % mitigated)

	var armor := ArmorComponent.new()
	armor.setup(5.0, {DefenseEnums.DamageType.FIRE: 0.5})
	var fire_damage: float = armor.mitigate(20.0, DefenseEnums.DamageType.FIRE)
	if not is_equal_approx(fire_damage, 7.5):
		failures.append("ArmorComponent.mitigate fire: expected 7.5, got %f" % fire_damage)
	var ballistic_damage: float = armor.mitigate(20.0, DefenseEnums.DamageType.BALLISTIC)
	if not is_equal_approx(ballistic_damage, 15.0):
		failures.append("ArmorComponent.mitigate ballistic (no resistance entry): expected 15, got %f" % ballistic_damage)

	return failures
