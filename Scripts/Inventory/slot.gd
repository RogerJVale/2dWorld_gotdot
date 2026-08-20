@tool
class_name Slot
extends Panel



@onready var slot: TextureRect = get_node("Icon")

@export var item: Item:
	set(value):
		print("Setting slot item")
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
	update_counter(0)

func clear_highlight():
	$Highlight.hide()

func highlight():
	$Highlight.show()

func update_counter(_amount: int):

	if _amount < 2:
		$Counter.hide()
	else:
		$Counter.show()
		$Counter.text = str(_amount)

func set_amount(value: int):
	amount = value
