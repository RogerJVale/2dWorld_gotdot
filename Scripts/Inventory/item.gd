extends Resource
class_name Item

@export var item_id: String
@export var name: String
@export var icon: Texture2D
@export var quantity: int = 1
@export var max_stack: int = 99
@export var prefab: PackedScene
@export var item_type: ItemType
@export var value: int = 1


enum ItemType {
	TOOL,
	MATERIAL,
	CONSUMABLE,
	QUEST
}
