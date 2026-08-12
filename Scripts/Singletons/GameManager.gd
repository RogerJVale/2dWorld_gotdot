extends Node2D

@export var stones := {}
@export var trees := {}
@export var plants := {}


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
			return TileTypes.tile_type_from_string(tile_type_str)
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
#region Drops
@export var dropped_items := {}

func store_drop(item: Item, amount: int):
	var player_pos = _player.position


	var drop : Node2D = spawn_drop(player_pos, item)
	var data = {"item":item, "amount": amount, "drop": drop}
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

func spawn_drop(player_pos: Vector2, item: Item)-> Node2D:
	var drop = preload("res://Scenes/WorldSprites/Drop/drop.tscn").instantiate()
	drop.world_position = player_pos
	drop.item = item
	add_child(drop)
	return drop

func pickup_drop(drop):
	var item = drop.item
	var amount = drop.amount
	inventory.add_item(item, amount)
#endregion


#####################
## Enviorment
######################

#region Enviormental health bar for distructable resources
var env_bar_active: bool = false
var env_bar_cell := Vector2i()
var enviorment_health_bar: ProgressBar

func check_enviorment():
	var type: TileTypes.Type = get_tile_data_at_marker_position("InFront")
	var current_cell = floor_marker.get_marker_cell()

	# If bar exists but tile changed → remove it
	if env_bar_active and current_cell != env_bar_cell:
		enviorment_health_bar.queue_free()
		enviorment_health_bar = null
		env_bar_active = false

	# Show bar only if not already active
	if type == TileTypes.Type.stone:
		if !env_bar_active:
			show_enviorment_health_bar(current_cell, stones[current_cell]["health"], type)
			env_bar_active = true
			env_bar_cell = current_cell
		return

	if type == TileTypes.Type.tree_stump:
		if !env_bar_active:
			show_enviorment_health_bar(current_cell, trees[current_cell]["health"], type)
			env_bar_active = true
			env_bar_cell = current_cell
		return

	# Not looking at a resource → remove bar
	if env_bar_active:
		enviorment_health_bar.queue_free()
		enviorment_health_bar = null
		env_bar_active = false

func damage_object(cell: Vector2i, amount: int, type: TileTypes.Type):
	if !enviorment_health_bar:
		return

	var data
	if type == TileTypes.Type.stone && stones.has(cell):
		data = stones[cell]
	elif type == TileTypes.Type.tree_stump && trees.has(cell):
		data = trees[cell]
	else:
		print("No data found")
		return


	data.health -= amount
	print("data health", data.health)

	# Update bar
	enviorment_health_bar.value = data.health
	# Destroy object if dead
	if data.health <= 0:
		destroy_object(cell, type)

func destroy_object(cell: Vector2i, type: TileTypes.Type):
	infront_layer.set_cell(cell, -1)  # remove tile

	var data = get_data_for_type(cell, type)
	if data == null: return
	match type:

		TileTypes.Type.stone:
			stones.erase(cell)

		TileTypes.Type.tree_stump:
			trees[cell]["sprite"].queue_free()
			var item : Item = load("res://Scripts/Inventory/Items/log.tres")
			store_drop(item, 1)

	enviorment_health_bar.queue_free()
	enviorment_health_bar = null
	env_bar_active = false

func show_enviorment_health_bar(cell: Vector2i, health: float, type: TileTypes.Type):
	var data

	if type == TileTypes.Type.stone:
		data = stones[cell]
	elif type == TileTypes.Type.tree_stump:
		data = trees[cell]
	else:
		return

	# Already has a bar?
	enviorment_health_bar = ProgressBar.new()
	enviorment_health_bar.min_value = 0
	enviorment_health_bar.max_value = data.max_health
	enviorment_health_bar.value = health
	enviorment_health_bar.size = Vector2(20, 1)
	enviorment_health_bar.modulate = Color.GREEN
	enviorment_health_bar.show_percentage = false
	var world_pos = infront_layer.map_to_local(floor_marker.get_marker_cell())
	enviorment_health_bar.position = world_pos + Vector2(-10, -15)
	enviorment_health_bar.z_index = 99
	enviorment_health_bar.scale = Vector2(1, 0.1)
	add_child(enviorment_health_bar)
#endregion
func get_data_for_type(cell: Vector2i, type: TileTypes.Type):

	if type == TileTypes.Type.stone && stones.has(cell):
		return stones[cell]
	elif type == TileTypes.Type.tree_stump && trees.has(cell):
		return trees[cell]
	else:
		return
