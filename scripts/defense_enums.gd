## Shared enums and constants for the defense-building subsystem.
## Plain RefCounted script with class_name so every enum is globally
## addressable (e.g. DefenseEnums.DamageType.BALLISTIC) without an autoload.
class_name DefenseEnums
extends RefCounted

enum Category {
	PASSIVE,
	ACTIVE,
}

## Build-menu grouping buckets (see docs/GAME_DESIGN.md UI section).
enum Subcategory {
	BARRIERS,
	GATES,
	GROUND_OBSTACLES,
	ENEMY_ROUTING,
	INFRASTRUCTURE_PROTECTION,
	DECOYS,
	BALLISTIC_WEAPONS,
	PRECISION_WEAPONS,
	EXPLOSIVE_WEAPONS,
	ENERGY_WEAPONS,
	AREA_DENIAL,
	ANTI_AIR,
	INTERCEPT_SHIELD,
	SENSORS,
	REPAIR_MAINTENANCE,
}

enum DamageType {
	BALLISTIC,
	EXPLOSIVE,
	FIRE,
	ENERGY,
	ELECTRIC,
	CHEMICAL,
	ACID,
	MELEE,
}

enum TargetType {
	GROUND,
	FLYING,
	PROJECTILE,
	SPECIAL,
}

enum TargetPriorityMode {
	NEAREST,
	FIRST_ON_PATH,
	LAST_ON_PATH,
	STRONGEST,
	WEAKEST,
	MOST_HEALTH,
	MOST_ARMOR,
	FASTEST,
	FLYING_ONLY,
	RANGED_UNITS,
	SIEGE_UNITS,
	SPECIAL,
}

enum RepairPriorityMode {
	NEXUS,
	ACTIVE_WEAPONS,
	PASSIVE_BARRIERS,
	SENSORS,
	POWER_SUPPLY,
	LOGISTICS,
	LOWEST_HEALTH_REMAINING,
}

enum GateState {
	OPEN,
	CLOSED,
	OPENING,
	CLOSING,
	BLOCKED,
	DESTROYED,
}

## Bitflags: a building can be in several of these simultaneously.
enum BuildingStatus {
	ACTIVE = 1,
	DISABLED = 2,
	NO_POWER = 4,
	NO_AMMO = 8,
	RELOADING = 16,
	OVERHEATED = 32,
	DAMAGED = 64,
	BURNING = 128,
	JAMMED = 256,
	BLOCKED = 512,
	OVERLOADED = 1024,
	DESTROYED = 2048,
}

## Named AStarGrid2D movement profiles owned by NavigationManager.
const PROFILE_GROUND_SMALL: String = "ground_small"
const PROFILE_GROUND_LARGE: String = "ground_large"
const PROFILE_FLYING: String = "flying"

const ALL_GROUND_PROFILES: Array[String] = [PROFILE_GROUND_SMALL, PROFILE_GROUND_LARGE]
const ALL_PROFILES: Array[String] = [PROFILE_GROUND_SMALL, PROFILE_GROUND_LARGE, PROFILE_FLYING]

## Groups used for cross-system contracts (see docs/DEFENSE_SYSTEMS.md).
const GROUP_DEFENSE_TARGETS: String = "defense_targets"
const GROUP_REPAIRABLE_BUILDINGS: String = "repairable_buildings"
const GROUP_NEXUS: String = "nexus"

## Default tile size in pixels, matches NavigationManager's default cell_size.
const TILE_SIZE: float = 64.0

## Physics collision layer bits (see DefenseBuilding._create_physics_body,
## TargetingComponent, SensorComponent, RepairProviderComponent). Areas only
## ever set collision_mask (what they detect); bodies only ever set
## collision_layer (what they are) - nothing needs to detect an Area.
const LAYER_DEFENSE_TARGETS: int = 1 # bit 0 - EnemyStub and future real enemies
const LAYER_BUILDINGS: int = 2 # bit 1 - every DefenseBuilding's physics body
const LAYER_SIGHT_BLOCKER: int = 4 # bit 2 - passive buildings currently blocking a tile
