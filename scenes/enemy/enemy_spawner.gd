## Debug-only spawner for manual testing - no timer, no waves, no balancing.
## Press 1/2/3/4 to spawn small/medium/heavy/flying test dummies at this
## node's position, so a tester can manually verify slowdown, targeting,
## and flying-ignores-ground-obstacles behavior.
extends Node2D

const EnemyStubScene := preload("res://scenes/enemy/enemy_stub.tscn")

@export var small_variant: EnemyStubData
@export var medium_variant: EnemyStubData
@export var heavy_variant: EnemyStubData
@export var flying_variant: EnemyStubData


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_1:
			spawn(small_variant)
		KEY_2:
			spawn(medium_variant)
		KEY_3:
			spawn(heavy_variant)
		KEY_4:
			spawn(flying_variant)


func spawn(variant: EnemyStubData) -> void:
	if variant == null:
		return
	var enemy: EnemyStub = EnemyStubScene.instantiate()
	enemy.setup(variant)
	enemy.global_position = global_position
	get_tree().current_scene.add_child(enemy)
