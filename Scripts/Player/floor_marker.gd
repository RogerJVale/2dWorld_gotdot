class_name  FloorMarker
extends Node2D

@export var tile_layer: TileMapLayer
@export var player: Node2D
@export var marker: Node2D

func _ready() -> void:
	SceneMagement.floor_marker = self

	GlobalSignals.hide_marker.connect(_hide_marker)

func set_tilemaplayer(tml : TileMapLayer):

	tile_layer = tml
func show_marker(weapon_type: String):

	var snapped_pos: Vector2 = get_marker_position()
	player.target_cell = snapped_pos
	#Move marker
	global_position = snapped_pos
	visible = true
	if GameManager.game_state == GameStates.GameState.BUILDING:
		$Sprite2D/Chest.show()
		return
	show_tool_action(weapon_type, snapped_pos)

func _hide_marker():
		hide()
		Utils.hide_children($Sprite2D)


func get_tile_data_at_marker_position(layer_name: String) -> TileTypes.Type:
	return GameManager.getTileData(get_marker_position(),layer_name)

func get_marker_position() -> Vector2i:

	var target_cell = get_marker_cell()
	# 5. Convert tile coordinate → world position
	return  tile_layer.to_global(tile_layer.map_to_local(target_cell))

func get_marker_cell() -> Vector2i:
	var player_pos: Vector2 = player.global_position

	# 2. Convert world → tile coordinate
	var cell: Vector2i = tile_layer.local_to_map(tile_layer.to_local(player_pos))

	# 3. Convert last_direction (Vector2) → tile offset (Vector2i)
	var dir := Vector2i(player.last_direction.x, player.last_direction.y)

	# 4. Move one tile forward in facing direction
	return  cell + dir


func show_tool_action(weapon_type: String, snapped_pos: Vector2):

	var data: TileTypes.Type = GameManager.getTileData(snapped_pos, "Ground")


	if weapon_type == "Axe" and GameManager.getTileData(snapped_pos,"InFront") == TileTypes.Type.tree_stump:
		$Sprite2D/AxeSwing.visible = true;
		$Sprite2D/AxeSwing.play_anim()
		player.play_attack_animation("2h_overswing")
		GameManager.damage_object(get_marker_cell(), 25, TileTypes.Type.tree_stump)
	elif weapon_type == "Shovel" and data == TileTypes.Type.grass:
		$Sprite2D/Shovel.visible = true;
		$Sprite2D/Shovel.play_anim()
	elif weapon_type == "WateringCan" and data == TileTypes.Type.dirt:
		$Sprite2D/WateringCan.visible = true;
		$Sprite2D/WateringCan.play_anim()
	elif weapon_type == "Pick" and GameManager.getTileData(snapped_pos,"InFront") == TileTypes.Type.stone:
		$Sprite2D/Pick.visible = true;
		$Sprite2D/Pick.play_anim()
		player.play_attack_animation("2h_overswing")
		GameManager.damage_object(get_marker_cell(), 25, TileTypes.Type.stone)

	else:
		## faile to do the correct task
		await get_tree().create_timer(0.5).timeout
		visible = false
