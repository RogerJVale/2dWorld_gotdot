class_name Hotbar
extends Control
@export var inventory : Inventory
@onready var slots : = []

var current_slot := 0
var selected_item: Item = null

func _process(_delta):
	if GameManager.game_state == GameManager.GameState.PLAY \
	or GameManager.game_state == GameManager.GameState.HOTBAR:
		if Input.is_action_just_pressed("nav_left"):
			current_slot = (current_slot - 1 + slots.size()) % slots.size()
			update_current_item()

		if Input.is_action_just_pressed("nav_right"):
			current_slot = (current_slot + 1) % slots.size()
			update_current_item()

	if GameManager.game_state == GameManager.GameState.HOTBAR:
		if Input.is_action_just_pressed("nav_up"):
			GameManager.game_state = GameManager.GameState.INVENTORY

		if Input.is_action_just_pressed("select"):
			remove_item_from_slot(current_slot)


func _ready() -> void:
	slots = $GridContainer.get_children()

	update_current_item()
	highlight_slot(current_slot)

	load_hotbar()

##############################
## Navigation
##############################
func add_item(item: Item) -> bool:
	for i in slots.size():
		if slots[i].item == null:
			slots[i].item = item
			if i == current_slot:
				update_current_item()
			return true

	return false

func remove_item_from_slot(index: int):
	if index < 0 or index >= slots.size():
		return
	print("Removing ", selected_item.name)

	if GameManager.game_state == GameManager.GameState.HOTBAR:
		if !inventory.add_item(slots[index].item):
			print("Failed to add item to inventory")


	slots[index].item = null

	if index == current_slot:
		update_current_item()

func swap_slots(a: int, b: int):
	if a < 0 or a >= slots.size():
		return
	if b < 0 or b >= slots.size():
		return

	var temp = slots[a].item
	slots[a].item = slots[b].item
	slots[b].item = temp

	if a == current_slot or b == current_slot:
		update_current_item()

func update_current_item():
	selected_item = slots[current_slot].item
	highlight_slot(current_slot)
	GameManager.equipped_item = selected_item

	if selected_item:
		print("Selected:", selected_item.name)
	else:
		print("Slot empty")

func highlight_slot(index):
	for i in slots.size():
		slots[i].clear_highlight()

	slots[index].highlight()
##################################
## Saving/loading
##################################
func save_hotbar():
	var items := []
	for slot in slots:
		items.append(slot.item)

	var save := Resource.new()
	save.set_meta("hotbar_items", items)

	ResourceSaver.save(save, "user://hotbar.tres")
	print("Hotbar saved")

func load_hotbar():
	if !FileAccess.file_exists("user://hotbar.tres"):
		print("No hotbar save found")
		return

	var save := load("user://hotbar.tres")
	var loaded = save.get_meta("hotbar_items")

	if loaded == null:
		print("Failed to load hotbar")
		return

	for i in slots.size():
		slots[i].item = loaded[i]

	update_current_item()
	print("Hotbar loaded")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_hotbar()

func _exit_tree():
	save_hotbar()
