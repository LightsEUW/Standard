## Support building: wires up a RepairProviderComponent from SupportData
## when the building actually provides repair (repair_radius > 0).
class_name SupportDefenseBuilding
extends ActiveDefenseBuilding

var repair_provider: RepairProviderComponent = null


func _ready() -> void:
	super._ready()
	var support_data: SupportData = data as SupportData
	if support_data == null:
		push_warning("SupportDefenseBuilding '%s' requires SupportData" % name)
		return

	if support_data.repair_radius > 0.0:
		repair_provider = RepairProviderComponent.new()
		add_child(repair_provider)
		repair_provider.setup(support_data)


func _collect_extra_ui_fields() -> Dictionary:
	if repair_provider == null:
		return {}
	return {"repair_radius": repair_provider.get_node("CollisionShape2D").shape.radius}
