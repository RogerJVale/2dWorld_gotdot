@tool
class_name Slot
extends ColorRect

@onready var slot: TextureRect = get_node("slot")

@export var item: Item:
	set(value):
		item = value
		if slot:
			slot.texture = item.icon if item else null

func _ready():
	if slot and item:
		slot.texture = item.icon
