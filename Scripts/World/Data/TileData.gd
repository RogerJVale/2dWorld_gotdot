class_name Tile_Data
extends  Resource
@export var worldPos: Vector2
@export var cell: Vector2i

@export var terrain_id: int = -1
@export var wet: bool = false
@export var fertilizer: int = 0

@export var plant_type: String = ""
@export var plant_growth: int = 0
@export var plant_water: float = 0.0
@export var plant_health: float = 1.0
@export var plant_timer: float = 0.0

#func save_to_file(path: String) -> void:
	#ResourceSaver.save(self, path)
#
#
#static func load_from_file(path: String) -> Tile_Data:
	#return ResourceLoader.load(path)
#
#
#
#
#
#
#func to_dict() -> Dictionary:
	#return {
		#"worldPos": [worldPos.x, worldPos.y],
		#"cell": [cell.x, cell.y],
#
		#"terrain_id": terrain_id,
		#"wet": wet,
		#"fertilizer": fertilizer,
#
		#"plant": {
			#"type": plant_type,
			#"growth": plant_growth,
			#"water": plant_water,
			#"health": plant_health,
			#"timer": plant_timer
		#}
	#}
#
#
#func from_dict(data: Dictionary) -> void:
	#worldPos = Vector2(data.worldPos[0], data.worldPos[1])
	#cell = Vector2i(data.cell[0], data.cell[1])
#
	#terrain_id = data.terrain_id
	#wet = data.wet
	#fertilizer = data.fertilizer
#
	#if data.has("plant"):
		#plant_type = data.plant.type
		#plant_growth = data.plant.growth
		#plant_water = data.plant.water
		#plant_health = data.plant.health
		#plant_timer = data.plant.timer
