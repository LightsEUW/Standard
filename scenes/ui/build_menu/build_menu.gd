## Build menu grouped by subcategory, built entirely from BuildingRegistry -
## no hardcoded per-building list. Adding a new .tres to res://data/defense
## makes it appear here automatically on next load.
class_name BuildMenu
extends Control

signal building_selected(data: DefenseBuildingData)

const SUBCATEGORY_LABELS: Dictionary = {
	DefenseEnums.Subcategory.BARRIERS: "Barrieren",
	DefenseEnums.Subcategory.GATES: "Tore",
	DefenseEnums.Subcategory.GROUND_OBSTACLES: "Bodenhindernisse",
	DefenseEnums.Subcategory.ENEMY_ROUTING: "Gegnerlenkung",
	DefenseEnums.Subcategory.INFRASTRUCTURE_PROTECTION: "Infrastrukturschutz",
	DefenseEnums.Subcategory.DECOYS: "Täuschung",
	DefenseEnums.Subcategory.BALLISTIC_WEAPONS: "Ballistische Geschütze",
	DefenseEnums.Subcategory.PRECISION_WEAPONS: "Präzisionsgeschütze",
	DefenseEnums.Subcategory.EXPLOSIVE_WEAPONS: "Explosivwaffen",
	DefenseEnums.Subcategory.ENERGY_WEAPONS: "Energiegeschütze",
	DefenseEnums.Subcategory.AREA_DENIAL: "Flächenkontrolle",
	DefenseEnums.Subcategory.ANTI_AIR: "Flugabwehr",
	DefenseEnums.Subcategory.INTERCEPT_SHIELD: "Abfang- und Schutzsysteme",
	DefenseEnums.Subcategory.SENSORS: "Sensorik",
	DefenseEnums.Subcategory.REPAIR_MAINTENANCE: "Reparatur und Wartung",
}

const CATEGORY_ORDER: Array[DefenseEnums.Category] = [
	DefenseEnums.Category.PASSIVE,
	DefenseEnums.Category.ACTIVE,
]

const CATEGORY_LABELS: Dictionary = {
	DefenseEnums.Category.PASSIVE: "Passive Verteidigung",
	DefenseEnums.Category.ACTIVE: "Aktive Verteidigung",
}


func _ready() -> void:
	custom_minimum_size = Vector2(260, 0)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	for category in CATEGORY_ORDER:
		_add_category_section(list, category)


func _add_category_section(list: VBoxContainer, category: DefenseEnums.Category) -> void:
	var category_header := Label.new()
	category_header.text = CATEGORY_LABELS.get(category, str(category))
	category_header.add_theme_font_size_override("font_size", 18)
	list.add_child(category_header)

	var buildings_by_subcategory: Dictionary = {}
	for building_data in BuildingRegistry.get_by_category(category):
		if not buildings_by_subcategory.has(building_data.subcategory):
			buildings_by_subcategory[building_data.subcategory] = []
		buildings_by_subcategory[building_data.subcategory].append(building_data)

	for subcategory in buildings_by_subcategory.keys():
		_add_subcategory_section(list, subcategory, buildings_by_subcategory[subcategory])


func _add_subcategory_section(list: VBoxContainer, subcategory: DefenseEnums.Subcategory, buildings: Array) -> void:
	var subcategory_label := Label.new()
	subcategory_label.text = SUBCATEGORY_LABELS.get(subcategory, str(subcategory))
	list.add_child(subcategory_label)

	for building_data in buildings:
		var button := Button.new()
		button.text = building_data.display_name
		button.tooltip_text = building_data.description
		button.disabled = building_data.scene_path.is_empty()
		button.pressed.connect(func(): building_selected.emit(building_data))
		list.add_child(button)
