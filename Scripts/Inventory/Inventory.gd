extends Node
class_name Inventory
@export var slots: Array[Slot]   # assign in inspector
var items: Array = []      # same size as slots

# navigation
var current_slot : int = 0
var selected_item: Item = null

#debug
@export var test_item: Item


func _ready():
	Console.add_command("Add", add_items_to_inventory)



	items.resize(slots.size())

	load_inventory()
	refresh_ui()

	#add_item(test_item)


func _process(delta: float) -> void:

	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()

	if GameManager.game_state == GameManager.GameState.INVENTORY:
		if Input.is_action_just_pressed("nav_left"):
			current_slot = (current_slot - 1 + slots.size()) % slots.size()
			update_current_item()

		if Input.is_action_just_pressed("nav_right"):
			current_slot = (current_slot + 1) % slots.size()
			update_current_item()

		if Input.is_action_just_pressed("nav_down"):
			GameManager.game_state = GameManager.GameState.HOTBAR
		if Input.is_action_just_pressed("select"):
			remove_item(current_slot)
#########################
## Usage Funcs
#########################
func add_item(new_item: Item) -> bool:

	print("Adding ", new_item.name , " to inventory")

	# 1. Try stacking
	for i in items.size():
		var data = items[i]
		if data != null and data["item"].item_id == new_item.item_id:
			if data["amount"] < data["item"].max_stack:
				data["amount"] += 1
				refresh_slot(i)
				print("Stacked item")
				return true

	# 2. Put into empty slot
	for i in items.size():
		if items[i] == null:
			items[i] = {
				"item": new_item,
				"amount": 1
			}
			refresh_slot(i)
			print("put item into new slot")
			return true

	return false

func remove_item(index: int):
	if $"../Hotbar".add_item(items[index]):
		print("Sucess")
	else:
		print("Should drop on floor TODO")
		return

	items[index] = null
	refresh_slot(index)

func swap_items(a: int, b: int):
	var temp = items[a]
	items[a] = items[b]
	items[b] = temp
	refresh_slot(a)
	refresh_slot(b)

func refresh_ui():
	for i in slots.size():
		refresh_slot(i)

func refresh_slot(i: int):
	var data = items[i]

	if data == null:
		slots[i].item = null
		slots[i].amount = 0
	else:
		slots[i].item = data["item"]
		slots[i].amount = data["amount"]


############################
## Saving
############################
func save_inventory():
	var save := Resource.new()
	save.set_meta("items", items)
	ResourceSaver.save(save, "user://inventory.tres")
	print("Inventory saved")

func load_inventory():
	if !FileAccess.file_exists("user://inventory.tres"):
		print("No inventory save found")
		return

	var save := load("user://inventory.tres")
	var loaded_items = save.get_meta("items")

	items = loaded_items

	for i in items.size():
		refresh_slot(i)

	print("Inventory loaded")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_inventory()

func _exit_tree():
	save_inventory()

############################
## Navigation
############################
func toggle_inventory():
	if $GridContainer.visible:
		$GridContainer.visible = false
		GameManager.game_state = GameManager.GameState.PLAY
	else:
		$GridContainer.visible = true
		GameManager.game_state = GameManager.GameState.INVENTORY

func update_current_item():
	selected_item = slots[current_slot].item
	highlight_slot(current_slot)


	if selected_item:
		print("Selected:", selected_item.name)
	else:
		print("Slot empty")

func highlight_slot(index):
	for i in slots.size():
		slots[i].clear_highlight()

	slots[index].highlight()

func add_items_to_inventory():
	add_item(preload("res://Scripts/Inventory/Items/axe.tres"))
	add_item(preload("res://Scripts/Inventory/Items/pick.tres"))
	add_item(preload("res://Scripts/Inventory/Items/shovel.tres"))
	add_item(preload("res://Scripts/Inventory/Items/watering_can.tres"))
