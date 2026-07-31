## Orchestrates targeting/ammo/heat/power checks and fires projectiles for
## any WeaponBuilding. Generic across all weapon types - behavior differences
## come entirely from the WeaponData resource, not from branching here.
class_name WeaponComponent
extends Node

signal fired(target: Node)

const GenericProjectileScene := preload("res://scenes/defense/projectile/generic_projectile.tscn")

var _data: WeaponData
var _turret_pivot: Node2D
var _ammo: AmmoComponent
var _heat: HeatComponent
var _power: PowerConsumerComponent
var _targeting: TargetingComponent
var _status: StatusComponent

var _fire_cooldown: float = 0.0
var _acquisition_elapsed: float = 0.0
var _acquiring_target: Node = null


func setup(data: WeaponData, turret_pivot: Node2D, ammo: AmmoComponent, heat: HeatComponent, power: PowerConsumerComponent, targeting: TargetingComponent, status: StatusComponent) -> void:
	_data = data
	_turret_pivot = turret_pivot
	_ammo = ammo
	_heat = heat
	_power = power
	_targeting = targeting
	_status = status


func _process(delta: float) -> void:
	if _data == null:
		return

	_fire_cooldown = max(0.0, _fire_cooldown - delta)

	var has_power: bool = _power == null or _power.poll_power()
	_status.set_flag(DefenseEnums.BuildingStatus.NO_POWER, not has_power)
	if _power != null:
		_power.set_active(false) # only _try_fire() marks it active again, for this frame

	var overheated: bool = _heat != null and _heat.is_overheated()
	_status.set_flag(DefenseEnums.BuildingStatus.OVERHEATED, overheated)

	var out_of_ammo: bool = _ammo != null and _ammo.capacity > 0 and _ammo.is_empty()
	_status.set_flag(DefenseEnums.BuildingStatus.NO_AMMO, out_of_ammo)
	_status.set_flag(DefenseEnums.BuildingStatus.RELOADING, _ammo != null and _ammo.is_reloading())

	if not has_power or overheated:
		_acquiring_target = null
		return

	var target: Node = _targeting.refresh_target()
	_status.set_flag(DefenseEnums.BuildingStatus.ACTIVE, target != null)
	if target == null:
		_acquiring_target = null
		return

	_aim_at(target, delta)

	if target != _acquiring_target:
		_acquiring_target = target
		_acquisition_elapsed = 0.0
	_acquisition_elapsed += delta

	if _fire_cooldown > 0.0:
		return
	if _acquisition_elapsed < _data.target_acquisition_time:
		return
	if not _is_aimed_at(target):
		return
	_try_fire(target)


func _aim_at(target: Node, delta: float) -> void:
	if _turret_pivot == null:
		return
	var desired_angle: float = _turret_pivot.global_position.angle_to_point(target.global_position)
	if _data.turret_rotation_speed <= 0.0:
		_turret_pivot.rotation = desired_angle
		return
	var max_step: float = deg_to_rad(_data.turret_rotation_speed) * delta
	_turret_pivot.rotation = rotate_toward(_turret_pivot.rotation, desired_angle, max_step)


func _is_aimed_at(target: Node) -> bool:
	if _turret_pivot == null or _data.turret_rotation_speed <= 0.0:
		return true
	var desired_angle: float = _turret_pivot.global_position.angle_to_point(target.global_position)
	return abs(angle_difference(_turret_pivot.rotation, desired_angle)) < deg_to_rad(5.0)


func _try_fire(target: Node) -> void:
	if _ammo != null and not _ammo.try_consume(1):
		return
	if _heat != null:
		_heat.add_heat(_data.heat_per_shot)
	if _power != null:
		_power.set_active(true)

	_spawn_projectile(target)
	_fire_cooldown = 1.0 / max(0.01, _data.fire_rate)
	fired.emit(target)


func _spawn_projectile(target: Node) -> void:
	var projectile := GenericProjectileScene.instantiate()
	get_tree().current_scene.add_child(projectile)
	var origin: Vector2 = _turret_pivot.global_position if _turret_pivot != null else global_position
	projectile.setup(origin, target, _data)


func rotate_toward(from: float, to: float, max_delta: float) -> float:
	var diff: float = angle_difference(from, to)
	if abs(diff) <= max_delta:
		return to
	return from + sign(diff) * max_delta
