## Single generic projectile shared by every weapon type, parametrized at
## spawn time by a WeaponData. Travels in a straight line to the target's
## position at fire time (not homing), then applies direct or splash
## damage through the same duck-typed take_damage contract every target
## (real or stub) implements.
class_name GenericProjectile
extends Node2D

const MAX_LIFETIME: float = 6.0

var _target: Node = null
var _target_position: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var _data: WeaponData
var _elapsed: float = 0.0
var _spent: bool = false


func setup(origin: Vector2, target: Node, data: WeaponData) -> void:
	global_position = origin
	_data = data
	_target = target
	_target_position = target.global_position if is_instance_valid(target) else origin
	var direction: Vector2 = origin.direction_to(_target_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	_velocity = direction * max(1.0, data.projectile_speed)
	rotation = direction.angle()


func _process(delta: float) -> void:
	if _spent:
		return
	_elapsed += delta
	global_position += _velocity * delta
	if global_position.distance_to(_target_position) < 8.0 or _elapsed >= MAX_LIFETIME:
		_impact()


func _impact() -> void:
	_spent = true
	if _data.splash_radius > 0.0:
		_apply_splash_damage()
	else:
		_apply_direct_damage()
	queue_free()


func _apply_direct_damage() -> void:
	if is_instance_valid(_target) and _target.has_method("take_damage"):
		_target.take_damage(_data.damage, _data.damage_type, _data.armor_penetration)


func _apply_splash_damage() -> void:
	for target in get_tree().get_nodes_in_group(DefenseEnums.GROUP_DEFENSE_TARGETS):
		if not is_instance_valid(target) or not target.has_method("is_alive") or not target.is_alive():
			continue
		if global_position.distance_to(target.global_position) <= _data.splash_radius:
			target.take_damage(_data.damage, _data.damage_type, _data.armor_penetration)

	if _data.can_damage_own_buildings:
		for building in get_tree().get_nodes_in_group(DefenseEnums.GROUP_REPAIRABLE_BUILDINGS):
			if is_instance_valid(building) and global_position.distance_to(building.global_position) <= _data.splash_radius:
				building.take_damage(_data.damage, _data.damage_type, _data.armor_penetration)
