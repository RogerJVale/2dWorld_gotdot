extends Resource
class_name Item

@export var item_id: String
@export var name: String
@export var icon: Texture2D
@export var max_stack: int = 99
@export var prefab: PackedScene
@export var item_type: ItemType


enum ItemType {
	TOOL,
	MATERIAL,
	CONSUMABLE,
	QUEST
}
