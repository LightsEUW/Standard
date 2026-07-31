## Minimal stand-in for the "defense_targets" duck-typed contract, used only
## by headless tests for TargetPriority - avoids needing a real EnemyStub
## (which depends on the NavigationManager/scene-tree at runtime).
extends Node2D

var alive: bool = true
var target_type: String = "ground"
var health: float = 10.0
var armor: float = 0.0
var speed: float = 50.0
var path_progress: float = 0.0


func is_alive() -> bool:
	return alive


func get_target_type() -> String:
	return target_type


func take_damage(_amount: float, _damage_type: int = 0, _armor_penetration: float = 0.0) -> void:
	pass


func get_health() -> float:
	return health


func get_max_health() -> float:
	return health


func get_armor() -> float:
	return armor


func get_speed() -> float:
	return speed


func get_path_progress() -> float:
	return path_progress
