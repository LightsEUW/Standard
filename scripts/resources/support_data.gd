## Data for support buildings (repair station, ...). RepairProviderComponent
## reads these fields to drive its repair radius/rate/priority generically.
class_name SupportData
extends ActiveDefenseData

@export var repair_radius: float = 150.0
@export var repair_amount_per_tick: float = 5.0
@export var repair_material_cost_per_tick: float = 1.0
@export var max_simultaneous_targets: int = 1
@export var default_repair_priority: DefenseEnums.RepairPriorityMode = DefenseEnums.RepairPriorityMode.LOWEST_HEALTH_REMAINING


func _init() -> void:
	super._init()
