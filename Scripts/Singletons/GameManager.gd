extends Node2D

enum GameState {
	PLAY,
	INVENTORY,
	HOTBAR
}
@export var game_state: GameState = GameState.PLAY
@export var start_scene : PackedScene


var minutes_per_second := 10.0  # how fast time moves
var day := 0
var minutes : float = 0

var _player: Movement
var equipped_item: Item

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
func _process(delta: float) -> void:

	process_time(delta)


	#handle the tool input
	#if (Input.is_action_just_pressed("place_tile")):
		#if equipped_item.name == "Shovel":
			#change_tile(_player.position)
##
## PLAYER UTILS
##
func register_player(player: CharacterBody2D):
	print("Player registered")
	_player = player
	SceneMagement.load_biome("grass_biome");

func set_2D_Platform():
	_player.enable_platformer_controls()

func set_top_dpwn():
	_player.enable_topdownControls()
##
## GET TILE DATA
##
func getTileData(pos:Vector2, layer: String):
	if SceneMagement.current_biome:
		var tilemap: TileMapLayer = SceneMagement.current_biome.get_node(layer);
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
	#print(Game Manager: SceneMagement.current_biome.name)
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
##########################
## Time Functions
##########################
#region Time Functions
func process_time(delta : float):

	minutes += minutes_per_second * delta


	if minutes >= 1440:
		day += 1
		minutes = 0

func get_hour() -> int:
	return int(minutes / 60)

func get_minute() -> int:
	return int(minutes) % 60

func get_day_progress() -> float:
	return minutes / 1440.0

func get_time_string() -> String:
	var h = get_hour()
	var m = get_minute()

	toggle_lights()

	return "%02d:%02d" % [h, m]
#endregion
#########################
## Lighting Controls
#########################
#region Lighting Controls
var is_night: bool = true
func toggle_lights():
	var h := get_hour()

	# Night: 18 → 24 OR 0 → 6
	if (h >= 18 or h < 6):
		if !is_night:
			is_night = true
			SceneMagement.current_biome.get_node_or_null("BiomeData").toggle_lights(true)
			print("lighting on")
	else:
		# Day: 6 → 18
		if is_night:
			is_night= false
			SceneMagement.current_biome.get_node_or_null("BiomeData").toggle_lights(false)
			print("lighting off")
#endregion
