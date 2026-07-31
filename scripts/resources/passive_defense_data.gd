## Data for passive defense: blocking/slowing/routing, no direct damage.
## passability_rules is the entire navigation contract - NavigationManager
## applies these generically and never special-cases a building by id.
## Each entry is a Dictionary with keys "profile" (String, one of
## DefenseEnums.PROFILE_*), "solid" (bool), "weight_scale" (float) - plain
## Dictionaries rather than a custom Resource subtype so these are simple
## and safe to hand-author directly in .tres files.
class_name PassiveDefenseData
extends DefenseBuildingData

@export var passability_rules: Array[Dictionary] = []

## Whether friendly units/repair drones may pass regardless of state
## (used by gates; ignored by plain walls).
@export var blocks_own_units: bool = false

## Durability lost each time an enemy crosses it (0 = doesn't apply, e.g. walls).
@export var durability_loss_per_cross: float = 0.0

@export var has_facing: bool = false
@export var frontal_resistance_multiplier: float = 1.0


func _init() -> void:
	category = DefenseEnums.Category.PASSIVE
