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

func show_marker():

	var player_pos: Vector2 = player.global_position
	var cell: Vector2i = tile_layer.local_to_map(tile_layer.to_local(player_pos))
	#Convert tile coordinate → snapped world position
	var snapped_pos: Vector2 = tile_layer.to_global(tile_layer.map_to_local(cell))
	# snap to the tile center
	#snapped_pos += tile_layer.tile_set.tile_size / 2.0
	# Move marker
	marker.global_position = snapped_pos
	visible = true

func toggle_marker(velocity: Vector2):
	if velocity == Vector2.ZERO:
		show_marker()
	else:
		visible = false;
	#if marker.visible:
		#marker.visible = false
	#else:
		#show_marker()
