## Reusable turret scene. lmg_turret, autocannon, mortar, light_flak, and
## weapon stubs all use this scene unmodified - firing behavior differences
## come entirely from the assigned WeaponData via WeaponComponent.
class_name GenericWeapon
extends WeaponBuilding

const TILE_SIZE: float = 64.0


func _ready() -> void:
	_setup_base_visual()
	var pivot := Node2D.new()
	pivot.name = "TurretPivot"
	add_child(pivot)
	var barrel := ColorRect.new()
	barrel.size = Vector2(28.0, 6.0)
	barrel.position = Vector2(0.0, -3.0)
	barrel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot.add_child(barrel)
	super._ready()


func _setup_base_visual() -> void:
	if data == null:
		return
	var rect := ColorRect.new()
	rect.size = Vector2(data.footprint_size) * TILE_SIZE
	rect.position = -rect.size / 2.0
	rect.color = Color(0.28, 0.3, 0.34)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
