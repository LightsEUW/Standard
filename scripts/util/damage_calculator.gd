## Static mitigation formula shared by every damage-dealing path (weapons,
## environmental effects, ...). Kept in one place so balancing the formula
## never means hunting through building scripts.
class_name DamageCalculator
extends RefCounted


## Returns the damage that actually gets through after armor + resistance.
## armor flatly reduces incoming damage before the resistance percentage is
## applied; resistance is a 0..1 fraction of the remaining damage absorbed.
static func calculate(raw_damage: float, armor: float, resistance: float, armor_penetration: float = 0.0) -> float:
	var effective_armor: float = max(0.0, armor - armor_penetration)
	var after_armor: float = max(0.0, raw_damage - effective_armor)
	var after_resistance: float = after_armor * (1.0 - clampf(resistance, 0.0, 1.0))
	return max(0.0, after_resistance)
