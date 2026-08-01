@tool
extends TextureRect

@export var item : Item:
	set(item_to_slot):
		item = item_to_slot
		texture = item.icon
