## Holds armor + per-damage-type resistances and mitigates incoming damage
## via DamageCalculator before it reaches HealthComponent.
class_name ArmorComponent
extends Node

var armor: float = 0.0
var resistances: Dictionary = {}
var frontal_resistance_multiplier: float = 1.0
var facing: Vector2 = Vector2.UP


func setup(p_armor: float, p_resistances: Dictionary) -> void:
	armor = p_armor
	resistances = p_resistances


func mitigate(raw_damage: float, damage_type: DefenseEnums.DamageType, armor_penetration: float = 0.0, from_direction: Vector2 = Vector2.ZERO) -> float:
	var resistance: float = resistances.get(damage_type, 0.0)
	if frontal_resistance_multiplier != 1.0 and from_direction != Vector2.ZERO:
		var is_frontal: bool = facing.dot(-from_direction.normalized()) > 0.5
		if is_frontal:
			resistance = clampf(resistance * frontal_resistance_multiplier, 0.0, 1.0)
	return DamageCalculator.calculate(raw_damage, armor, resistance, armor_penetration)
