## Reusable "block/slow + take damage + resist" scene. Wooden barricade,
## stone wall, protective wall, and most passive stubs all use this scene
## unmodified - all differences come from the assigned DefenseBuildingData.
class_name GenericObstacle
extends PassiveDefenseBuilding

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
	rect.color = Color(0.45, 0.42, 0.38)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
