## Turret building: wires Ammo/Heat(if used)/Targeting/Weapon components
## together from WeaponData. Scenes may include a child Node2D named
## "TurretPivot" to rotate visually; falls back to rotating the whole
## building if none is present.
class_name WeaponBuilding
extends ActiveDefenseBuilding

var ammo: AmmoComponent = null
var heat: HeatComponent = null
var targeting: TargetingComponent
var weapon: WeaponComponent


func _ready() -> void:
	super._ready()
	var weapon_data: WeaponData = data as WeaponData
	if weapon_data == null:
		push_warning("WeaponBuilding '%s' requires WeaponData" % name)
		return

	if weapon_data.ammo_capacity > 0:
		ammo = AmmoComponent.new()
		add_child(ammo)
		ammo.setup(weapon_data.required_ammo_type, weapon_data.ammo_capacity, weapon_data.reload_time)

	if weapon_data.max_heat > 0.0:
		heat = HeatComponent.new()
		add_child(heat)
		heat.setup(weapon_data.max_heat, weapon_data.cooldown_rate)

	targeting = TargetingComponent.new()
	add_child(targeting)
	targeting.setup(self, weapon_data)

	var turret_pivot: Node2D = get_node_or_null("TurretPivot")
	if turret_pivot == null:
		turret_pivot = self

	weapon = WeaponComponent.new()
	add_child(weapon)
	weapon.setup(weapon_data, turret_pivot, ammo, heat, power, targeting, status)


func _collect_extra_ui_fields() -> Dictionary:
	var weapon_data: WeaponData = data as WeaponData
	var fields: Dictionary = {
		"range": weapon_data.range if weapon_data != null else 0.0,
		"fire_rate": weapon_data.fire_rate if weapon_data != null else 0.0,
	}
	if ammo != null:
		fields["ammo"] = "%d / %d" % [ammo.current_ammo, ammo.capacity]
	if heat != null:
		fields["heat"] = "%.0f / %.0f" % [heat.current_heat, heat.max_heat]
	if targeting != null:
		fields["target"] = targeting.current_target.name if targeting.current_target != null else "-"
	return fields
