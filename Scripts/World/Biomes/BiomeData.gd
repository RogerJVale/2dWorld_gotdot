class_name BiomeData
extends Node



var tile_data: Array[Tile_Data] = []

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
