@tool
extends Node2D

@export var tileset: TileSet
@export var source_id: int
# These are atlas coordinates, NOT tile IDs
@export var ground_tile_coords: Array[Vector2i] = [Vector2i(0, 0)]
@export var map_size := Vector2i(200, 200)   # list of tile IDs to choose from
@export var layer_names: Array[String] = ["Ground", "InFront", "Collision", "AbovePlayer"]

@export var create_layers: bool = false:
	set(value):
		if value:
			_create_tilemap_layers()
		create_layers = false


func _create_tilemap_layers():
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
