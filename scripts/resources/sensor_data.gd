## Data for sensor buildings (watchtower, radar, ...). SensorComponent
## registers with the SensorNetwork autoload using these fields.
class_name SensorData
extends ActiveDefenseData

@export var sensor_range: float = 400.0
@export var requires_line_of_sight: bool = true
@export var detects_flying: bool = true
@export var detects_hidden: bool = false
@export var feeds_targeting_network: bool = true


func _init() -> void:
	super._init()
