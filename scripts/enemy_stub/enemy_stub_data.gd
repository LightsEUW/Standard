## Data for a minimal test dummy - NOT a real enemy/AI system. Just enough
## to give weapons something to detect, target, and damage while manually
## testing the defense subsystem.
class_name EnemyStubData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var size_class: String = "small" # "small" / "medium" / "heavy"
@export var movement_profile: String = DefenseEnums.PROFILE_GROUND_SMALL
@export var max_health: int = 20
@export var armor: float = 0.0
@export var speed: float = 60.0
@export var is_flying: bool = false
