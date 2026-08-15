extends Node
class_name Inventory

@export var inventory_id: String = "default_inventory"
@export var chest_id: String = "Chest_01"
@export var slots: Array[Slot]
@export var chest_slots: Array[Slot]

var items: Array = []
var chest_items: Array = []

# navigation
var current_slot: int = 0
var selected_item: Item = null

var current_chest_slot: int = 0
var selected_chest_item: int
var chest_active

# >>> ADDED <<<
# unified navigation context
var active_slots: Array[Slot]
var active_items: Array
var active_current_slot: int

#debug
@export var test_item: Item

@onready var inventory_grid_container: GridContainer = $BookPanelContainer/HSplitContainer/LeftPagePanel/InventoryGridContainer
@onready var chest_grid_container: GridContainer = $BookPanelContainer/HSplitContainer/RightPagePanel/ChestGridContainer
@onready var book_panel_container: PanelContainer = $BookPanelContainer
@onready var crafting: Node2D = $BookPanelContainer/HSplitContainer/RightPagePanel/Crafting

func _ready():
	GlobalSignals.open_chest_inventory.connect(_on_open_chest)
	GlobalSignals.open_crafting_menu.connect(_on_open_crafting_menu)

	slots = []
	for child: Slot in inventory_grid_container.get_children():
		slots.append(child)

	load_inventory(inventory_id, items)
	refresh_ui()

	# >>> ADDED <<<
	set_inventory_active()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()

	if GameManager.game_state == GameStates.GameState.INVENTORY \
	or GameManager.game_state == GameStates.GameState.CHEST:

		if Input.is_action_just_pressed("nav_left"):
			active_current_slot = (active_current_slot - 1 + active_slots.size()) % active_slots.size()
			update_active_item()

		if Input.is_action_just_pressed("nav_right"):
			active_current_slot = (active_current_slot + 1) % active_slots.size()
			update_active_item()

		if Input.is_action_just_pressed("nav_down"):

			# Chest is open → swap between inventory and chest
			if $PanelContainer/HSplitContainer/Panel2/ChestGridContainer.visible:

				if chest_active:
					# Chest → Inventory
					chest_active = false
					set_inventory_active()
					GameManager.game_state = GameStates.GameState.INVENTORY
				else:
					# Inventory → Chest
					chest_active = true
					set_chest_active()
					GameManager.game_state = GameStates.GameState.CHEST

			else:
				# Chest is NOT open → swap between Inventory → Hotbar
				GameManager.game_state = GameStates.GameState.HOTBAR

		if Input.is_action_just_pressed("select"):
			if chest_active:

				move_selected_item_from_chest_to_inventory()
			elif $PanelContainer/HSplitContainer/Panel2/ChestGridContainer.visible:

				move_selected_item_to_chest()
			else:

				remove_item_to_hotbar(active_current_slot)

		if Input.is_action_just_pressed("drop"):
			if chest_active:
				drop_chest_item()
			else:
				drop_item()

#########################
## Usage Funcs
#########################
func add_item(new_item: Item, amount: int = 0) -> bool:
	print("Adding ", amount, " ", new_item.name, " to inventory")

	var qty: int
	if amount == 0:
		qty = new_item.quantity
	else:
		qty = amount

	for i in items.size():
		var data = items[i]
		if data != null and data["item"].item_id == new_item.item_id:
			if data["amount"] + qty <= data["item"].max_stack:
				data["amount"] += qty
				refresh_slot(i)
				print("Stacked item ", qty)
				return true

	for i in items.size():
		if items[i] == null:
			items[i] = {"item": new_item, "amount": qty}
			refresh_slot(i)
			print("put item into new slot")
			return true

	return false

func add_stack(data: Dictionary) -> bool:
	var item = data["item"]
	var amount = data["amount"]

	for i in items.size():
		var slot = items[i]
		if slot != null and slot["item"].item_id == item.item_id:
			if slot["amount"] + amount <= slot["item"].max_stack:
				slot["amount"] += amount
				refresh_slot(i)
				return true

	for i in items.size():
		if items[i] == null:
			items[i] = {"item": item, "amount": amount}
			refresh_slot(i)
			return true

	return false

func remove_item_to_hotbar(index: int):
	var data = items[index]
	if data == null:
		return

	if $"../Hotbar".add_item(items[index]):
		print("Moved stack to hotbar")
	else:
		print("Should drop on floor TODO")
		return

	remove_item_from_inventory(index)

func remove_item_from_inventory(index: int):
	items[index] = null
	refresh_slot(index)

func drop_item():
	var data = items[active_current_slot]
	var item = data["item"]
	var amount = data["amount"]
	print("Droping ", item.name)
	GameManager.store_drop(item, amount)
	remove_item_from_inventory(active_current_slot)

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
	if items.size() < 1:
		return

	var data = items[i]

	if data == null:
		slots[i].item = null
		slots[i].amount = 0
	else:
		slots[i].item = data["item"]
		slots[i].amount = data["amount"]

#region Saving
func save_inventory(id, target_array):
	var save := Resource.new()
	save.set_meta("items", target_array)
	var path = "user://inventory_%s.tres" % id
	ResourceSaver.save(save, path)
	print("Inventory saved id " , id)

func load_inventory(id, target_array):
	var path = "user://inventory_%s.tres" % id

	if !FileAccess.file_exists(path):
		print("No inventory save found")
		target_array.clear()
		return

	var save := load(path)
	var loaded_items = save.get_meta("items")

	target_array.clear()
	for item in loaded_items:
		target_array.append(item)

	print("Inventory loaded")

#endregion

############################
# Chest
###########################
#region Chest
func _on_open_chest(id: String):
	chest_id = id
	print("opeing chest id : ", chest_id)
	chest_active = true
	book_panel_container.visible = true
	inventory_grid_container.show()
	chest_grid_container.show()

	chest_slots = []
	for child: Slot in chest_grid_container.get_children():
		chest_slots.append(child)

	load_inventory(chest_id, chest_items)
	chest_items.resize(chest_slots.size())
	refresh_chest_ui()

	# >>> ADDED <<<
	set_chest_active()
	GameManager.game_state = GameStates.GameState.CHEST

func _on_close_chest():
	save_inventory(chest_id, chest_items)

func refresh_chest_ui():
	for i in chest_slots.size():
		refresh_chest_slot(i)

func refresh_chest_slot(i):
	if chest_items.size() < 1:
		return

	var data = chest_items[i]

	if data == null:
		chest_slots[i].item = null
		chest_slots[i].amount = 0
	else:
		chest_slots[i].item = data["item"]
		chest_slots[i].amount = data["amount"]

func move_selected_item_to_chest():
	# Only allow moving when inventory is active
	if chest_active:
		return
	print("trying to move item to chest")
	var index := active_current_slot
	var data = items[index]

	if data == null:
		return

	var item = data["item"]
	var amount = data["amount"]

	# 1. Try stacking into chest
	for i in chest_items.size():
		var cdata = chest_items[i]
		if cdata != null and cdata["item"].item_id == item.item_id:
			if cdata["amount"] + amount <= cdata["item"].max_stack:
				cdata["amount"] += amount
				refresh_chest_slot(i)
				remove_item_from_inventory(index)
				return

	# 2. Try empty chest slot
	for i in chest_items.size():
		if chest_items[i] == null:
			chest_items[i] = {
				"item": item,
				"amount": amount
			}
			refresh_chest_slot(i)
			remove_item_from_inventory(index)
			return

	# 3. Chest full
	print("Chest full — cannot move item")

func move_selected_item_from_chest_to_inventory():
	if !chest_active:
		return

	var index := active_current_slot
	var data = chest_items[index]

	if data == null:
		return

	var item = data["item"]
	var amount = data["amount"]

	# Try adding to inventory using your existing add_item()
	if add_item(item, amount):
		# Remove from chest
		chest_items[index] = null
		refresh_chest_slot(index)
	else:
		print("Inventory full — cannot move item")

func drop_chest_item():
#endregion
	var index := active_current_slot
	var data = chest_items[index]
	var item = data["item"]
	var amount = data["amount"]
	print("Droping ", item.name)
	GameManager.store_drop(item, amount)
	# Remove from chest
	chest_items[index] = null
	refresh_chest_slot(index)
###########################
## Crafting
###########################
func _on_open_crafting_menu():
	crafting.show()
	toggle_inventory()

############################
## Navigation
############################
func set_inventory_active():
	active_slots = slots
	active_items = items
	active_current_slot = current_slot
	chest_active = false

func set_chest_active():
	active_slots = chest_slots
	active_items = chest_items
	active_current_slot = current_chest_slot
	chest_active = true

func update_active_item():
	selected_item = active_slots[active_current_slot].item
	highlight_active_slot(active_current_slot)

func highlight_active_slot(index):
	for i in active_slots.size():
		active_slots[i].clear_highlight()
	active_slots[index].highlight()

func toggle_inventory():
	if inventory_grid_container.visible:
		inventory_grid_container.visible = false

		GameManager.game_state = GameStates.GameState.PLAY
		save_inventory(inventory_id, items)
		if chest_grid_container.visible:
			chest_grid_container.hide()
			_on_close_chest()
		if crafting.visible:
			crafting.hide()
	else:
		inventory_grid_container.visible = true
		set_inventory_active()
		GameManager.game_state = GameStates.GameState.INVENTORY

	book_panel_container.visible = inventory_grid_container.visible
func add_items_to_inventory():
	add_item(preload("res://Scripts/Inventory/Items/axe.tres"))
	add_item(preload("res://Scripts/Inventory/Items/pick.tres"))
	add_item(preload("res://Scripts/Inventory/Items/shovel.tres"))
	add_item(preload("res://Scripts/Inventory/Items/watering_can.tres"))
	add_item(preload("res://Scripts/Inventory/Items/log.tres"))
