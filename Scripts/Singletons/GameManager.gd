extends Node2D

@export var game_state: GameStates.GameState = GameStates.GameState.PLAY
@export var start_scene : PackedScene

#refrences
var infront_layer: TileMapLayer
var floor_marker: FloorMarker
var mini_dialog: MiniDialog
var _player: Movement
var inventory: Inventory

#settings
var minutes_per_second := 10.0  # how fast time moves
var day := 0
var minutes : float = 0


var equipped_item: Item



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var main = get_tree().get_root().get_node("Main")
	floor_marker = main.get_node("FloorMarker")
	mini_dialog = main.get_node("MiniDialog")
	inventory = main.get_node("CanvasLayer/Inventory")

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

	infront_layer = SceneMagement.current_biome.get_node("InFront")

func set_2D_Platform():
	_player.enable_platformer_controls()

func set_top_dpwn():
	_player.enable_topdownControls()

func handle_tile_type(type: String):
	pass

##
## GET TILE DATA
##
func getTileData(pos:Vector2, layer: String)->TileTypes.Type:
	if SceneMagement.current_biome:
		var tilemap: TileMapLayer = SceneMagement.current_biome.get_node(layer);
		if not tilemap:
			print("Did not find tile map")

		var cell := tilemap.local_to_map(pos)
		var data: TileData = tilemap.get_cell_tile_data(cell)

		if data:
			var tile_type_str: String = data.get_custom_data("type")
			# Convert string → enum safely
			if TileTypes.Type.has(tile_type_str):
				return TileTypes.Type[tile_type_str]
			else:
				print("Unknown tile type: ", tile_type_str)
				return TileTypes.Type.EMPTY

	return TileTypes.Type.EMPTY

func get_tile_data_at_marker_position(layer_name: String)->TileTypes.Type:
	return getTileData(floor_marker.get_marker_position(),layer_name)

##
## SAVING AND LOADING TILE CHANGES
## change the cell tile without saving
func change_map_cell_no_save(cell: Vector2i):
	var tilemap: TileMapLayer = SceneMagement.current_biome.get_node("Ground");
	#auto tile
	#print(Game Manager: SceneMagement.current_biome.name)
	tilemap.set_cells_terrain_connect([cell], 0, 1, false)

func change_tile(pos: Vector2):
	print("Chaning tile using mouse")
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
	var biome_data = SceneMagement.current_biome.get_node_or_null("BiomeData")
	if biome_data == null:
		return
	# Night: 18 → 24 OR 0 → 6
	if (h >= 18 or h < 6):
		if !is_night:
			is_night = true
			biome_data.toggle_lights(true)
			print("lighting on")
	else:
		# Day: 6 → 18
		if is_night:
			is_night = false
			biome_data.toggle_lights(false)
			print("lighting off")
#endregion
########################
## Drops
########################
@export var dropped_items := {}

func store_drop(item: Item, amount: int):
	var player_pos = _player.position
	var drop : Node2D = spawn_drop(player_pos, item, amount)
	var data = {"item":item, "amount":amount, "drop": drop}
	dropped_items[player_pos] = data

func remove_drop(drop_pos):
	if dropped_items.has(drop_pos):
		var data = dropped_items.get(drop_pos)
		data.drop.queue_free()
		dropped_items.erase(drop_pos)

func check_for_drop_nearby(player_pos: Vector2):
	for drop_pos in dropped_items.keys():
		if player_pos.distance_to(drop_pos) < 20:
			mini_dialog.show_dialog("E to pickup",
							func():
							mini_dialog.hide_dialog()
							pickup_drop(dropped_items.get(drop_pos))
							remove_drop(drop_pos)
							)
			return
	if mini_dialog.visible:
		mini_dialog.hide_dialog()

func spawn_drop(player_pos: Vector2, item: Item, amount: int)-> Node2D:
	var drop = preload("res://Scenes/WorldSprites/Drop/drop.tscn").instantiate()
	drop.world_position = player_pos
	drop.item = item
	drop.amount = amount
	add_child(drop)
	return drop

func pickup_drop(drop):
	var item = drop.item
	var amount = drop.amount
	inventory.add_item(item, amount)
