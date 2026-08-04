class_name Hotbar
extends Control

@onready var slots : = []

var current_slot := 0
var current_item: Item = null

func _process(_delta):
	if Input.is_action_just_pressed("nav_left"):
		current_slot = max(current_slot - 1, 0)
		update_current_item()

	if Input.is_action_just_pressed("nav_right"):
		current_slot = min(current_slot + 1, slots.size() - 1)
		update_current_item()



func _ready() -> void:
	slots = $GridContainer.get_children()

	update_current_item()
	highlight_slot(current_slot)


func update_current_item():
	current_item = slots[current_slot].item
	highlight_slot(current_slot)
	GameManager.equipped_item = current_item

	if current_item:
		print("Selected:", current_item.name)
	else:
		print("Slot empty")

func highlight_slot(index):
	for i in slots.size():
		slots[i].clear_highlight()

	slots[index].highlight()
