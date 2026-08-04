@tool
class_name Slot
extends Panel

@onready var slot: TextureRect = get_node("Icon")

@export var item: Item:
	set(value):
		item = value
		if slot:
			slot.texture = item.icon if item else null

func _ready():
	if slot and item:
		slot.texture = item.icon

func clear_highlight():
	$Highlight.modulate = Color.WHITE

func highlight():
	$Highlight.modulate = Color.YELLOW
