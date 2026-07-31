## Passive defense: registers its passability with NavigationManager.
## Subclasses with unique behavior (gate, spike field, protective wall)
## override _get_current_passability() instead of touching navigation code.
class_name PassiveDefenseBuilding
extends DefenseBuilding

var nav_obstacle: NavObstacleComponent


func _ready() -> void:
	super._ready()
	if data == null:
		return
	nav_obstacle = NavObstacleComponent.new()
	add_child(nav_obstacle)
	nav_obstacle.setup(get_footprint_cells())
	nav_obstacle.apply_rules(_get_current_passability())
	_update_sight_blocking()

	if data.has_facing and armor != null:
		armor.frontal_resistance_multiplier = data.frontal_resistance_multiplier
		armor.facing = Vector2.UP.rotated(rotation)


## Override in subclasses whose passability changes at runtime (e.g. a gate
## that only blocks while closed). Default: whatever the data says, always.
func _get_current_passability() -> Array[Dictionary]:
	var passive_data: PassiveDefenseData = data as PassiveDefenseData
	return passive_data.passability_rules if passive_data != null else ([] as Array[Dictionary])


func _refresh_passability() -> void:
	if nav_obstacle != null:
		nav_obstacle.apply_rules(_get_current_passability())
	_update_sight_blocking()


## Only currently-solid passive buildings block line of sight (e.g. an open
## gate lets both enemies and sightlines through). Toggling this bit is
## cheap and keeps LOS raycasts from needing to know about building types.
func _update_sight_blocking() -> void:
	if physics_body == null:
		return
	var blocks_sight: bool = _get_current_passability().any(func(rule): return rule.get("solid", false))
	if blocks_sight:
		physics_body.collision_layer = DefenseEnums.LAYER_BUILDINGS | DefenseEnums.LAYER_SIGHT_BLOCKER
	else:
		physics_body.collision_layer = DefenseEnums.LAYER_BUILDINGS


func _on_died() -> void:
	super._on_died()
	if nav_obstacle != null:
		nav_obstacle.revert()
