## Never solid - purely a weight_scale-based slowdown via PassabilityRule
## data (different weight per ground profile, no entry for flying). The one
## bit of unique behavior is losing durability while an enemy crosses it.
class_name SpikeField
extends PassiveDefenseBuilding

const TICK_INTERVAL: float = 0.5
const TILE_SIZE: float = 64.0

var _detector: Area2D
var _tick_elapsed: float = 0.0


func _ready() -> void:
	super._ready()
	_detector = Area2D.new()
	_detector.monitoring = true
	_detector.monitorable = false
	_detector.collision_layer = 0
	_detector.collision_mask = 0
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = (Vector2(data.footprint_size) * TILE_SIZE).length() * 0.5
	shape.shape = circle
	_detector.add_child(shape)
	add_child(_detector)
	_setup_visual()


func _process(delta: float) -> void:
	var passive_data: PassiveDefenseData = data as PassiveDefenseData
	if passive_data.durability_loss_per_cross <= 0.0 or health == null:
		return
	_tick_elapsed += delta
	if _tick_elapsed < TICK_INTERVAL:
		return
	_tick_elapsed = 0.0
	var being_crossed: bool = _detector.get_overlapping_bodies().any(func(b):
		return is_instance_valid(b) and b.is_in_group(DefenseEnums.GROUP_DEFENSE_TARGETS) \
			and b.has_method("is_alive") and b.is_alive() \
			and b.has_method("get_target_type") and b.get_target_type() == "ground"
	)
	if being_crossed:
		take_damage(passive_data.durability_loss_per_cross, DefenseEnums.DamageType.MELEE)


func _setup_visual() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(data.footprint_size) * TILE_SIZE
	rect.position = -rect.size / 2.0
	rect.color = Color(0.5, 0.3, 0.25)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
