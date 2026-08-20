extends Camera2D

@export var tilemap_layer: TileMapLayer
@export var player: Node2D

var world_size: Vector2

func setup():
	print("Camera setup")
	tilemap_layer = GameManager.infront_layer
	player = GameManager._player
	world_size = Utils.calculate_world_size(tilemap_layer)


func _process(_delta):
	_follow_player()
	_clamp_camera()





func _follow_player():
	# Child camera: DO NOT set global_position
	# Camera automatically follows parent (player)
	# So this function does nothing
	pass


func _clamp_camera():
	# Correct zoom-aware screen size
	var half_screen = (get_viewport().get_visible_rect().size / zoom) * 0.5

	var min_x = half_screen.x
	var max_x = world_size.x - half_screen.x

	var min_y = half_screen.y
	var max_y = world_size.y - half_screen.y

	# Child camera: clamp OFFSET, not position
	var cam_pos = global_position

	cam_pos.x = clamp(cam_pos.x, min_x, max_x)
	cam_pos.y = clamp(cam_pos.y, min_y, max_y)

	# Convert clamped global position back into local offset
	offset = cam_pos - player.global_position


#extends Camera2D
#
#@export var tilemap_layer: TileMapLayer
#@export var player: Node2D
#
#var world_size: Vector2
#
#func setup():
	#print("Camera setup")
	#tilemap_layer = GameManager.infront_layer
	#player = GameManager._player
	#_calculate_world_size()
#
#
#func _process(delta):
	#_follow_player()
	#_clamp_camera()
#
#
#func _calculate_world_size():
	#var used = tilemap_layer.get_used_rect()
	#var tile_size = tilemap_layer.tile_set.tile_size
	#world_size = used.size * tile_size
#
#
#func _follow_player():
	## FIX: Camera2D must follow using GLOBAL position
	#global_position = player.global_position
#
#
#func _clamp_camera():
	#var half_screen = (get_viewport().get_visible_rect().size / zoom) * 0.5
#
	#var min_x = half_screen.x
	#var max_x = world_size.x - half_screen.x
#
	#var min_y = half_screen.y
	#var max_y = world_size.y - half_screen.y
#
	#var cam_pos = global_position
#
	#cam_pos.x = clamp(cam_pos.x, min_x, max_x)
	#cam_pos.y = clamp(cam_pos.y, min_y, max_y)
#
	#set_global_position(cam_pos)
