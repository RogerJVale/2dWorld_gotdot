class_name  FloorMarker
extends Node2D

@export var tile_layer: TileMapLayer
@export var player: Node2D
@export var marker: Node2D

func _ready() -> void:
	SceneMagement.floor_marker = self

#func _process(delta):
	## 1. Player world position
	#var player_pos: Vector2 = player.global_position
#
	## 2. Convert world → tile coordinate
	#var cell: Vector2i = tile_layer.local_to_map(tile_layer.to_local(player_pos))
#
	## 3. Convert tile coordinate → snapped world position
	#var snapped_pos: Vector2 = tile_layer.to_global(tile_layer.map_to_local(cell))
	## 3a. snap to the tile center
	##snapped_pos += tile_layer.tile_set.tile_size / 2.0
#
	## 4. Move marker
	#marker.global_position = snapped_pos

func set_tilemaplayer(tml : TileMapLayer):

	tile_layer = tml
func show_marker(weapon_type: String):
	# 1. Player world position
	var player_pos: Vector2 = player.global_position

	# 2. Convert world → tile coordinate
	var cell: Vector2i = tile_layer.local_to_map(tile_layer.to_local(player_pos))

	# 3. Convert last_direction (Vector2) → tile offset (Vector2i)
	var dir := Vector2i(player.last_direction.x, player.last_direction.y)

	# 4. Move one tile forward in facing direction
	var target_cell: Vector2i = cell + dir

	# 5. Convert tile coordinate → world position
	var snapped_pos: Vector2 = tile_layer.to_global(tile_layer.map_to_local(target_cell))
	player.target_cell = snapped_pos
	# 6. Move marker
	marker.global_position = snapped_pos
	visible = true



	show_tool_action(weapon_type, snapped_pos)




func show_tool_action(weapon_type: String, snapped_pos: Vector2):

	var data: String = GameManager.getTileData(snapped_pos, "Ground")


	if weapon_type == "Axe" and GameManager.getTileData(snapped_pos,"InFront") == "tree_stump":
		$Sprite2D/AxeSwing.visible = true;
		$Sprite2D/AxeSwing.play_anim()
	elif weapon_type == "Shovel" and data == "grass":
		$Sprite2D/Shovel.visible = true;
		$Sprite2D/Shovel.play_anim()
	elif weapon_type == "WateringCan" and data == "dirt":
		$Sprite2D/WateringCan.visible = true;
		$Sprite2D/WateringCan.play_anim()
	else:
		## faile to do the correct task
		await get_tree().create_timer(0.5).timeout
		visible = false
