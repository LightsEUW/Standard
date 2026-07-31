## Sensor building: wires up a SensorComponent from SensorData.
class_name SensorBuilding
extends ActiveDefenseBuilding

var sensor: SensorComponent


func _ready() -> void:
	super._ready()
	var sensor_data: SensorData = data as SensorData
	if sensor_data == null:
		push_warning("SensorBuilding '%s' requires SensorData" % name)
		return

	sensor = SensorComponent.new()
	add_child(sensor)
	sensor.setup(sensor_data)


func _collect_extra_ui_fields() -> Dictionary:
	if sensor == null:
		return {}
	return {"detected_targets": sensor.get_detected_targets().size()}
