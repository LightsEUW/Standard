## Thin registry of active SensorComponents. Weapons with
## requires_sensor_link=true query this instead of hardcoding a dependency
## on a specific watchtower/radar building.
extends Node

var _sensors: Array = []


func register_sensor(sensor: SensorComponent) -> void:
	if not _sensors.has(sensor):
		_sensors.append(sensor)


func unregister_sensor(sensor: SensorComponent) -> void:
	_sensors.erase(sensor)


func get_all_detected_targets() -> Array:
	var seen: Dictionary = {}
	for sensor in _sensors:
		if not is_instance_valid(sensor):
			continue
		for target in sensor.get_detected_targets():
			seen[target] = true
	return seen.keys()


func has_active_sensors() -> bool:
	return _sensors.any(func(s): return is_instance_valid(s))
