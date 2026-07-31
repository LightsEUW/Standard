## Automatic gate: opens for friendly units, closes automatically on enemy
## alarm, needs power to actively move but fails safe (stays/goes closed)
## without it. Passability is re-derived from GateStateComponent.state each
## time it changes - PassiveDefenseData.passability_rules describes the
## CLOSED configuration; OPEN simply clears the "solid" flag.
class_name AutomaticGate
extends PassiveDefenseBuilding

@export var alarm_radius: float = 200.0
@export var friendly_detection_radius: float = 80.0

var gate_state: GateStateComponent
var power: PowerConsumerComponent = null

var _alarm_area: Area2D
var _friendly_area: Area2D


func _ready() -> void:
	super._ready()

	if data.power_idle_draw > 0.0 or data.power_active_draw > 0.0:
		power = PowerConsumerComponent.new()
		add_child(power)
		power.setup(self, data.power_idle_draw, data.power_active_draw)

	gate_state = GateStateComponent.new()
	add_child(gate_state)
	gate_state.setup(1.0, power)
	gate_state.state_changed.connect(func(_s): _refresh_passability())

	_alarm_area = _make_detector(alarm_radius)
	add_child(_alarm_area)
	_friendly_area = _make_detector(friendly_detection_radius)
	add_child(_friendly_area)

	_setup_visual()


func _process(_delta: float) -> void:
	if gate_state.state == DefenseEnums.GateState.DESTROYED or gate_state.state == DefenseEnums.GateState.BLOCKED:
		return

	var enemy_nearby: bool = _alarm_area.get_overlapping_bodies().any(func(b):
		return is_instance_valid(b) and b.is_in_group(DefenseEnums.GROUP_DEFENSE_TARGETS) \
			and b.has_method("is_alive") and b.is_alive()
	)
	if enemy_nearby:
		gate_state.request_close()
		return

	var friendly_nearby: bool = _friendly_area.get_overlapping_bodies().any(func(b):
		return is_instance_valid(b) and b.is_in_group("friendly_units")
	)
	if friendly_nearby:
		gate_state.request_open()
	else:
		gate_state.request_close()


func _get_current_passability() -> Array[Dictionary]:
	var passive_data: PassiveDefenseData = data as PassiveDefenseData
	if gate_state == null:
		return passive_data.passability_rules
	var is_blocking: bool = gate_state.is_blocking()
	var rules: Array[Dictionary] = []
	for base_rule in passive_data.passability_rules:
		rules.append({
			"profile": base_rule.get("profile", ""),
			"solid": is_blocking and base_rule.get("solid", false),
			"weight_scale": base_rule.get("weight_scale", 1.0),
		})
	return rules


func _on_died() -> void:
	if gate_state != null:
		gate_state.mark_destroyed()
	super._on_died()


func _make_detector(radius: float) -> Area2D:
	var area := Area2D.new()
	area.monitoring = true
	area.monitorable = false
	area.collision_layer = 0
	area.collision_mask = 0
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	area.add_child(shape)
	return area


func _setup_visual() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(data.footprint_size) * 64.0
	rect.position = -rect.size / 2.0
	rect.color = Color(0.6, 0.55, 0.2)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)


func _collect_extra_ui_fields() -> Dictionary:
	return {"gate_state": DefenseEnums.GateState.keys()[gate_state.state] if gate_state != null else "-"}
