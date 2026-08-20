class_name Hotbar
extends Control
@export var inventory : Inventory
@onready var slots : = []

var current_slot := 0
var selected_item: Item = null

func _process(_delta):
	if GameManager.game_state == GameStates.GameState.PLAY \
	or GameManager.game_state == GameStates.GameState.HOTBAR:
		if Input.is_action_just_pressed("nav_left"):
			current_slot = (current_slot - 1 + slots.size()) % slots.size()
			update_current_item()

		if Input.is_action_just_pressed("nav_right"):
			current_slot = (current_slot + 1) % slots.size()
			update_current_item()

	if GameManager.game_state == GameStates.GameState.HOTBAR:
		if Input.is_action_just_pressed("nav_up"):
			GameManager.game_state = GameStates.GameState.INVENTORY

		if Input.is_action_just_pressed("select"):
			remove_item(current_slot)


func _ready() -> void:
	slots = $GridContainer.get_children()

	update_current_item()
	highlight_slot(current_slot)

	load_hotbar()

##############################
## Navigation
##############################
func add_item(data) -> bool:
	# data = { "item": Item, "amount": int }

	for i in slots.size():
		var slot = slots[i]

		if slot.item == null:
			slot.item = data["item"]
			slot.amount = data["amount"]

			if i == current_slot:
				update_current_item()
			save_hotbar()
			return true

	return false
func remove_item(index: int):
	var slot = slots[index]

	if slot.item == null:
		return

	var data = {
		"item": slot.item,
		"amount": slot.amount
	}

	if $"../Inventory".add_stack(data):
		# Clear hotbar slot
		slot.item = null
		slot.amount = 0
		update_current_item()
		print("Moved stack to inventory")
	else:
		print("Inventory full — drop on floor TODO")

	save_hotbar()

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
	GlobalSignals.player_swapped_weapon.emit(selected_item)
	GameManager.equipped_item = selected_item

	#if selected_item:
		#print("Selected:", selected_item.name)
	#else:
		#print("Slot empty")

func highlight_slot(index):
	for i in slots.size():
		slots[i].clear_highlight()

	slots[index].highlight()
##################################
## Saving/loading
##################################
func save_hotbar():
	var save_data := []

	for i in slots.size():
		var slot = slots[i]

		save_data.append({
			"item": slot.item,
			"amount": slot.amount
		})

	var save := Resource.new()
	save.set_meta("hotbar", save_data)
	ResourceSaver.save(save, "user://hotbar.tres")
	print("Hotbar saved")

func load_hotbar():
	if !FileAccess.file_exists("user://hotbar.tres"):
		print("No hotbar save found")
		return

	var save := load("user://hotbar.tres")
	var data = save.get_meta("hotbar")

	if data == null:
		print("Failed to load hotbar")
		return

	for i in data.size():
		var entry = data[i]
		slots[i].item = entry["item"]
		slots[i].amount = entry["amount"]

	update_current_item()
	print("Hotbar loaded")
