extends Node
class_name TileTypes
enum Type{
	EMPTY,
	grass,
	stone,
	WATER,
	SAND,
	tree_stump,
	drop,
	dirt,
}

static func tile_type_from_string(tile_type_str: String) -> int:
	if TileTypes.Type.has(tile_type_str):
		return TileTypes.Type[tile_type_str]
	else:
		print("Unknown tile type: ", tile_type_str)
		return TileTypes.Type.EMPTY
