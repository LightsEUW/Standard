## Marker base for the active-defense family (weapons, sensors, support).
## Category-specific fields live on WeaponData / SensorData / SupportData.
class_name ActiveDefenseData
extends DefenseBuildingData


func _init() -> void:
	category = DefenseEnums.Category.ACTIVE
