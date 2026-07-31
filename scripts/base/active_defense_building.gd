## Active defense: always registers power consumption. WeaponBuilding /
## SensorBuilding / SupportDefenseBuilding add their own components on top.
class_name ActiveDefenseBuilding
extends DefenseBuilding

var power: PowerConsumerComponent = null


func _ready() -> void:
	super._ready()
	if data == null:
		return
	if data.power_idle_draw > 0.0 or data.power_active_draw > 0.0:
		power = PowerConsumerComponent.new()
		add_child(power)
		power.setup(self, data.power_idle_draw, data.power_active_draw)
