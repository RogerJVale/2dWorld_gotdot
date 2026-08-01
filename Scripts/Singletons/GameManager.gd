extends Node2D


@export var start_scene : PackedScene

var _player: Movement

func _ready() -> void:
	pass
func _process(delta: float) -> void:

	if (Input.is_action_just_pressed("place_tile")):
		change_tile(_player.position)
##
## PLAYER UTILS
##
func register_player(player: CharacterBody2D):
	_player = player
	SceneMagement.load_biome("GrassBiome");

func set_2D_Platform():
	_player.enable_platformer_controls()

func set_top_dpwn():
	_player.enable_topdownControls()
##
## GET TILE DATA
##
func getTileData(pos:Vector2):
	if SceneMagement.current_biome:
		var tilemap: TileMapLayer = SceneMagement.current_biome.get_node("Ground");
		if not tilemap:
			print("Did not find tile map")

		var cell := tilemap.local_to_map(pos)
		var data: TileData = tilemap.get_cell_tile_data(cell)

		if data:
			var tile_type: String = data.get_custom_data("type")

			return tile_type
##
## SAVING AND LOADING TILE CHANGES
## change the cell tile without saving
func change_map_cell_no_save(cell: Vector2i):
	var tilemap: TileMapLayer = SceneMagement.current_biome.get_node("Ground");
	#auto tile
	print(SceneMagement.current_biome.name)
	tilemap.set_cells_terrain_connect([cell], 0, 1, false)

func change_tile(pos: Vector2):
	print("Chaning tileusing mouse")
	if SceneMagement.current_biome:
		var tilemap: TileMapLayer = SceneMagement.current_biome.get_node("Ground");
		if not tilemap:
			print("Did not find tile map")
		var cell := tilemap.local_to_map(pos)

		#swap tile with a replacement
		#tilemap.set_cell(cell,1,tile_atlas_position)

		#auto tile
		tilemap.set_cells_terrain_connect([cell], 0, 1, false)

		var biome_data: BiomeData = SceneMagement.current_biome.get_node("BiomeData")
		if biome_data:
			# set and store the new tile data
			var tile_data = Tile_Data.new()
			tile_data.worldPos = pos
			tile_data.cell = cell
			biome_data.add_new_tile(tile_data)
		else:
			print("GameManager: No data to save  ")

#func change_tile_tilemap_position(cell: Vector2, tile_atlas_position: Vector2):
	#if SceneMagement.current_biome:
		#var tilemap: TileMapLayer = SceneMagement.current_biome.get_node("Ground");
		#if tilemap:
			#tilemap.set_cell(cell,1,tile_atlas_position)
		#else:
			#print("Did not find tile map")
