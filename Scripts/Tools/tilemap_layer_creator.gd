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
@export var infront_tilemap: TileMapLayer


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
@export var spawn_resources: bool = false:
	set(value):
		if value:
			_spawn_resources()
		spawn_resources = false


var noise_val = []

var tree_stump_id : int = 0
var tree_stump_atlas_pos : Vector2i = Vector2i(8,9)
@export var tree_stump_max_spawn: int = 50

var stone_id : int = 0
var stone_atlas_pos : Vector2i = Vector2i(15,18)
@export var stone_max_spawn: int = 50

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
			var cell : Vector2i = Vector2i(x,y)

			if n >= sand_cap: #sand
				cells_sand.append(cell)
			if n > grass_cap:
				cells_grass.append(cell)
			if n > dirt_cap:
				cells_dirt.append(cell)
			if n > cliff_cap:
				cells_cliff.append(cell)


	ground_tilemap.set_cells_terrain_connect(cells_sand,0,0)
	grass_tilemap.set_cells_terrain_connect(cells_grass,1,0)
	dirt_tilemap.set_cells_terrain_connect(cells_dirt,2,0)
	cliff_tilemap.set_cells_terrain_connect(cells_cliff, 3,0)

	for cell in cells_dirt:
		grass_tilemap.erase_cell(cell)
	for cell in cells_cliff:
		dirt_tilemap.erase_cell(cell)

	print("generation Completed")
	print("min _noise ", noise_val.min())
	print("max noise", noise_val.max())
	print("sand cells count ", cells_sand.size())
	print("grass cells count ", cells_grass.size())

func _spawn_resources():
	# clear layer
	for x in map_size.x:
		for y in map_size.y:
			infront_tilemap.set_cell(Vector2i(x,y), -1)

	place_random_tiles(grass_tilemap, infront_tilemap, tree_stump_id, tree_stump_atlas_pos,tree_stump_max_spawn)
	place_random_tiles(dirt_tilemap, infront_tilemap, stone_id, stone_atlas_pos,stone_max_spawn)


func place_random_tiles(
	source_layer: TileMapLayer,
	target_layer: TileMapLayer,
	tile_id: int,
	atlas_pos: Vector2i,
	max_amount: int
):
	# 1. Get all used cells from the source layer
	var used := source_layer.get_used_cells()

	if used.is_empty():
		return

	# 2. Shuffle the list so we get random positions
	used.shuffle()

	# 3. Limit to the maximum amount requested
	var count = min(max_amount, used.size())

	# 4. Place tiles on the target layer
	for i in count:
		var cell := used[i]
		target_layer.set_cell(cell, tile_id, atlas_pos)

func is_cell_used(layer: TileMapLayer, cell: Vector2i) -> bool:
	return layer.get_cell_source_id(cell) != -1
