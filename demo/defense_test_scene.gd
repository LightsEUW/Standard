## Manual verification scene (see docs/GAME_DESIGN.md verification plan).
## Builds a tile corridor from a fixed enemy spawn point down to a Nexus
## placeholder, pre-places all 11 "first version" buildings to form a
## realistic funnel, and wires up the build menu / placement preview /
## info panel UI so a tester can also hand-place additional buildings.
## Cannot be run in this development session (no Godot engine available) -
## open this scene in the Godot editor and press Play to verify.
extends Node2D

const CELL_SIZE: Vector2 = Vector2(64.0, 64.0)
const MAP_SIZE_CELLS: Vector2i = Vector2i(30, 22)

const CORRIDOR_TOP_Y: int = 2
const CORRIDOR_BOTTOM_Y: int = 17
const WEST_WALL_X: int = 13
const EAST_WALL_X: int = 17
const GATE_Y_START: int = 9

const BuildMenuScene := preload("res://scenes/ui/build_menu/build_menu.tscn")
const PlacementPreviewScene := preload("res://scenes/ui/placement_preview/placement_preview.tscn")
const BuildingInfoPanelScene := preload("res://scenes/ui/building_info_panel/building_info_panel.tscn")
const EnemySpawnerScene := preload("res://scenes/enemy/enemy_spawner.tscn")

const SmallEnemyData := preload("res://data/enemy_stub/small_ground.tres")
const MediumEnemyData := preload("res://data/enemy_stub/medium_ground.tres")
const HeavyEnemyData := preload("res://data/enemy_stub/heavy_ground.tres")
const FlyingEnemyData := preload("res://data/enemy_stub/flying.tres")


func _ready() -> void:
	NavigationManager.configure(MAP_SIZE_CELLS, CELL_SIZE)

	_create_nexus(Vector2i(15, 19))
	_create_spawn_point(Vector2i(15, 1))
	_build_corridor_walls()

	_place_building("spike_field", Vector2i(14, 6))
	_place_building("spike_field", Vector2i(15, 6))
	_place_building("spike_field", Vector2i(16, 6))

	_place_building("watchtower", Vector2i(15, 9))
	_place_building("autocannon", Vector2i(14, 12))
	_place_building("lmg_turret", Vector2i(16, 12))
	_place_building("light_flak", Vector2i(15, 14))

	_place_building("mortar", Vector2i(11, 10))
	_place_building("repair_station", Vector2i(11, 13))

	var protective_wall: Node = _place_building("protective_wall", Vector2i(12, 14))
	if protective_wall != null:
		protective_wall.rotation = -PI / 2.0 # face east, toward the corridor
	_create_generator_dummy(Vector2i(10, 14))

	_predamage_wall_near(Vector2i(13, 13))

	_setup_ui()
	_setup_camera()

	var spawner: Node2D = EnemySpawnerScene.instantiate()
	spawner.global_position = Vector2(Vector2i(15, 1)) * CELL_SIZE + CELL_SIZE * 0.5
	spawner.small_variant = SmallEnemyData
	spawner.medium_variant = MediumEnemyData
	spawner.heavy_variant = HeavyEnemyData
	spawner.flying_variant = FlyingEnemyData
	add_child(spawner)


func _build_corridor_walls() -> void:
	for y in range(CORRIDOR_TOP_Y, CORRIDOR_BOTTOM_Y + 1):
		_place_building("stone_wall", Vector2i(WEST_WALL_X, y))
		if y == GATE_Y_START:
			_place_building("automatic_gate", Vector2i(EAST_WALL_X, y))
		elif y == GATE_Y_START + 1:
			pass # occupied by the gate's 1x2 footprint
		else:
			_place_building("stone_wall", Vector2i(EAST_WALL_X, y))


func _place_building(id: String, cell: Vector2i) -> Node:
	var data: DefenseBuildingData = BuildingRegistry.get_by_id(id)
	if data == null or data.scene_path.is_empty():
		push_warning("DefenseTestScene: cannot place '%s' (missing data or scene)" % id)
		return null
	var scene: PackedScene = load(data.scene_path)
	var instance: Node2D = scene.instantiate()
	instance.data = data
	instance.origin_cell = cell
	instance.global_position = Vector2(cell) * CELL_SIZE + Vector2(data.footprint_size) * CELL_SIZE * 0.5
	add_child(instance)
	return instance


func _predamage_wall_near(cell: Vector2i) -> void:
	for child in get_children():
		if child is DefenseBuilding and child.origin_cell == cell:
			child.take_damage(child.data.max_health * 0.6, DefenseEnums.DamageType.BALLISTIC)
			return


func _create_nexus(cell: Vector2i) -> void:
	var data := DefenseBuildingData.new()
	data.id = "nexus"
	data.display_name = "Nexus"
	data.max_health = 500
	data.armor = 2.0
	data.footprint_size = Vector2i(3, 3)
	data.repairable = true
	data.destructible = true

	var nexus := DefenseBuilding.new()
	nexus.data = data
	nexus.origin_cell = cell
	nexus.global_position = Vector2(cell) * CELL_SIZE + Vector2(data.footprint_size) * CELL_SIZE * 0.5
	add_child(nexus)
	nexus.add_to_group(DefenseEnums.GROUP_NEXUS)

	var visual := ColorRect.new()
	visual.size = Vector2(data.footprint_size) * CELL_SIZE
	visual.position = -visual.size / 2.0
	visual.color = Color(0.7, 0.6, 0.1)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nexus.add_child(visual)


func _create_spawn_point(cell: Vector2i) -> void:
	var marker := Marker2D.new()
	marker.global_position = Vector2(cell) * CELL_SIZE + CELL_SIZE * 0.5
	marker.add_to_group("enemy_spawn_points")
	add_child(marker)


func _create_generator_dummy(cell: Vector2i) -> void:
	var data := DefenseBuildingData.new()
	data.id = "demo_generator"
	data.display_name = "Generator (Demo)"
	data.max_health = 80
	data.armor = 0.0
	data.footprint_size = Vector2i(1, 1)
	data.repairable = true
	data.destructible = true

	var generator := DefenseBuilding.new()
	generator.data = data
	generator.origin_cell = cell
	generator.global_position = Vector2(cell) * CELL_SIZE + CELL_SIZE * 0.5
	add_child(generator)

	var visual := ColorRect.new()
	visual.size = CELL_SIZE
	visual.position = -visual.size / 2.0
	visual.color = Color(0.5, 0.5, 0.8)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	generator.add_child(visual)


func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var build_menu: BuildMenu = BuildMenuScene.instantiate()
	canvas.add_child(build_menu)

	var placement_preview: PlacementController = PlacementPreviewScene.instantiate()
	add_child(placement_preview)
	build_menu.building_selected.connect(placement_preview.start_placement)

	var info_panel: BuildingInfoPanel = BuildingInfoPanelScene.instantiate()
	info_panel.placement_controller = placement_preview
	canvas.add_child(info_panel)


func _setup_camera() -> void:
	var camera := Camera2D.new()
	camera.position = Vector2(15, 10) * CELL_SIZE
	camera.zoom = Vector2(0.9, 0.9)
	camera.enabled = true
	add_child(camera)
	camera.make_current()
