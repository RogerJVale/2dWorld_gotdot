@tool
class_name Slot
extends Panel



@onready var slot: TextureRect = get_node("Icon")

@export var item: Item:
	set(value):
		item = value
		if slot:
			slot.texture = item.icon if item else null

@export var amount: int = 0:
	set(value):
		amount = value
		update_counter(value)

func _ready():
	if slot and item:
		slot.texture = item.icon

func clear_highlight():
	$Highlight.modulate = Color.WHITE

func highlight():
	$Highlight.modulate = Color.YELLOW

func update_counter(amount: int):

	if amount < 2:
		$Counter.hide()
	else:
		$Counter.show()
		$Counter.text = str(amount)
