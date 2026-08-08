extends Node2D
class_name Drop

@export var world_position: Vector2
@export var lifetime := 100.0   # seconds before auto-despawn
@export var item: Item
@export var amount:int
@onready var texture_rect: TextureRect = $TextureRect

var tilemap_layer: TileMapLayer


func _ready():
	texture_rect.texture = item.icon
	position = world_position
	await get_tree().create_timer(lifetime).timeout
	queue_free()
