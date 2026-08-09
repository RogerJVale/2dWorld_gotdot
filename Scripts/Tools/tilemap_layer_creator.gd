@tool
extends Node2D


@export var tileset: TileSet
@export var source_id: int
# These are atlas coordinates, NOT tile IDs
@export var ground_tile_coords: Array[Vector2i] = [Vector2i(0, 0)]
@export var map_size := Vector2i(50, 50)   # list of tile IDs to choose from
@export var layer_names: Array[String] = ["Ground", "InFront", "Collision", "AbovePlayer"]


@export var ground_tilemap: TileMapLayer
@export var grass_tilemap: TileMapLayer
@export var dirt_tilemap: TileMapLayer
@export var cliff_tilemap: TileMapLayer
@export var sand_cap: float = -0.7
@export var grass_cap: float = -0.0
@export var dirt_cap: float = 0.5
@export var cliff_cap: float = 0.6

@export var create_layers: bool = false:
	set(value):
		if value:
			_create_tilemap_layers()
		create_layers = false

@export var create_base_world: bool = false:
	set(value):
		if value:
			_create_base_tile_map()
		create_layers = false;
var noise_val = []
func _create_tilemap_layers():
	print("Map generation Started")
	if tileset == null:
		push_error("No TileSet assigned!")
		return

	# Ensure tiles are 16x16
	tileset.tile_size = Vector2i(16, 16)

	for _name in layer_names:
		if has_node(_name):
			push_warning("TileMapLayer '%s' already exists, skipping." % _name)
			continue

		var layer := TileMapLayer.new()
		layer.name = _name
		layer.tile_set = tileset

		# Set draw order based on index
		layer.z_index = layer_names.find(_name) * 10

		add_child(layer)
		layer.owner = get_tree().edited_scene_root

		if _name == "Ground":
			_fill_ground(layer)

	print("TileMapLayer nodes created.")

func _fill_ground(layer: TileMapLayer):
	if ground_tile_coords.is_empty():
		push_error("No ground tile IDs provided!")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for x in map_size.x:
		for y in map_size.y:
			var atlas_coord := ground_tile_coords[rng.randi_range(0, ground_tile_coords.size() - 1)]
			layer.set_cell(Vector2i(x, y), source_id, atlas_coord)


func _create_base_tile_map():

	var noise = FastNoiseLite.new()
	noise.seed = 100

	print("clearing map")
	for x in map_size.x:
		for y in map_size.y:
			ground_tilemap.set_cell(Vector2i(x,y), -1)
			grass_tilemap.set_cell(Vector2i(x,y), -1)
			dirt_tilemap.set_cell(Vector2i(x,y), -1)
			cliff_tilemap.set_cell(Vector2i(x,y), -1)
	print("map cleared")

	var cells_sand = []
	var cells_grass = []
	var cells_dirt = []
	var cells_cliff = []
	for x in map_size.x:
		for y in map_size.y:
			var n = noise.get_noise_2d(x,y)
			noise_val.append(n)


			if n >= sand_cap: #sand
				if n > grass_cap:
					cells_grass.append(Vector2(x,y))
					if n > dirt_cap:
						cells_dirt.append(Vector2(x,y))
						if n > cliff_cap:
							cells_cliff.append(Vector2(x,y))
				cells_sand.append(Vector2(x,y))

	ground_tilemap.set_cells_terrain_connect(cells_sand,0,0)
	grass_tilemap.set_cells_terrain_connect(cells_grass,1,0)
	dirt_tilemap.set_cells_terrain_connect(cells_dirt,2,0)
	cliff_tilemap.set_cells_terrain_connect(cells_cliff, 3,0)


	print("generation Completed")
	print("min _noise ", noise_val.min())
	print("max noise", noise_val.max())
	print("sand cells count ", cells_sand.size())
	print("grass cells count ", cells_grass.size())
