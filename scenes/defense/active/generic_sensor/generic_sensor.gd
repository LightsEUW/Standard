## Reusable sensor scene. Watchtower and sensor stubs use this unmodified -
## detection behavior comes entirely from the assigned SensorData.
class_name GenericSensor
extends SensorBuilding

const TILE_SIZE: float = 64.0


func _ready() -> void:
	super._ready()
	_setup_visual()


func _setup_visual() -> void:
	if data == null:
		return
	var rect := ColorRect.new()
	rect.size = Vector2(data.footprint_size) * TILE_SIZE
	rect.position = -rect.size / 2.0
	rect.color = Color(0.2, 0.35, 0.4)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
