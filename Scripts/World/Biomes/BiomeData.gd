class_name BiomeData
extends Node

# lighitng (not surer why this is here)
@export var lights: Array[PointLight2D]  = []
var lights_active:bool
var directional_light: DirectionalLight2D



var tile_data: Array[Tile_Data] = []


func _ready() -> void:
	# grab all the point lights in the scene
	for child in get_children():
		if child is PointLight2D:
			lights.append(child)
	directional_light = get_node("DirectionalLight2D")

func add_new_tile(tile : Tile_Data):
	for t in tile_data:
		if t.worldPos == tile.worldPos:
			print("Adding tile failed")
			return  # duplicate tile, skip

	tile_data.append(tile)
	print("tile added " , tile_data.size())


func save_all_tiles_as_res(biomeName: String):
	var data := TileMap_Data.new()
	data.tiles = tile_data
	ResourceSaver.save(data, "user://" + biomeName + ".tres")


func load_all_tiles_from_res(biomeName: String):
	if not FileAccess.file_exists("user://" + biomeName + ".tres"):
		return

	#get the data from the resousce file
	var data: TileMap_Data = ResourceLoader.load("user://" + biomeName + ".tres")
	tile_data = data.tiles

	#draw the tiles on the biome
	for tile in tile_data:
		GameManager.change_map_cell_no_save(tile.cell)

	register_resource_tiles()
	spawn_trees_from_stumps()

func spawn_trees_from_stumps() -> void:
	var tilemap_layer = $"../InFront"
	var tree_scene := preload("res://Scenes/WorldSprites/small_oak_tree.tscn")

	# Loop all used cells on this layer
	for cell in tilemap_layer.get_used_cells():
		var tile_data : TileData = tilemap_layer.get_cell_tile_data(cell)
		if tile_data == null:
			continue

		# Assuming you set a custom data key "tree_stump" = true on that tile
		var tile_type: String = tile_data.get_custom_data("type")
		if tile_type == "tree_stump":
			# Tile center in local/world space
			var pos = tilemap_layer.map_to_local(cell)

			var tree = tree_scene.instantiate()
			tree.position = pos

			tilemap_layer.get_parent().add_child(tree)

			# Optional: clear the stump tile
			# tilemap_layer.set_cell(cell, -1)
## place all resources in there dictionarys
## all resources are placed on th inFront layer
### so wi will scnat that layer only
func register_resource_tiles():
	var tilemap_layer = $"../InFront"
	# Loop all used cells on this layer
	for cell in tilemap_layer.get_used_cells():
		var tile_data : TileData = tilemap_layer.get_cell_tile_data(cell)
		if tile_data == null:
			continue

		# Assuming you set a custom data key "tree_stump" = true on that tile
		var tile_type: String = tile_data.get_custom_data("type")
		var tile_type_enum = TileTypes.tile_type_from_string(tile_type)
		match tile_type:
			"tree_stump":
				GameManager.trees[cell] = {
					"max_health" : 200,
					"health": 200,
					"type": "tree",
					"bar" : null
				}
			"stone":
				GameManager.stone[cell] = {
					"max_health" : 100,
					"health": 100,
					"type": "rock",
					"bar" : null
				}







## debug code to create ajson file for readablity as the resource file will be hard to read
func save_debug_json():
	var arr := []
	for t in tile_data:
		arr.append({
			"cell": t.cell,
			"world_position": t.world_position,
			"terrain_id": t.terrain_id,
			"plant_type": t.plant_type
		})

	var json := JSON.stringify(arr, "    ")
	FileAccess.open("user://world_debug.json", FileAccess.WRITE).store_string(json)

func toggle_lights(is_night : bool):
	# sun
	directional_light.visible = !is_night
	#scene lights
	for light in lights:
		light.visible = is_night
