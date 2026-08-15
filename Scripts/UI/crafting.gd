extends Node

@export var inventory : Inventory
@onready var slots : = []

var current_slot := 0
var selected_item: Item = null

func _process(_delta):
	if GameManager.game_state == GameStates.GameState.CRAFTING :
		if Input.is_action_just_pressed("nav_left"):
			current_slot = (current_slot - 1 + slots.size()) % slots.size()
			update_current_item()

		if Input.is_action_just_pressed("nav_right"):
			current_slot = (current_slot + 1) % slots.size()
			update_current_item()

	if GameManager.game_state == GameStates.GameState.CRAFTING:
		if Input.is_action_just_pressed("nav_up"):
			GameManager.game_state = GameStates.GameState.INVENTORY

		if Input.is_action_just_pressed("select"):
			#remove_item(current_slot)
			pass

func update_current_item():
	selected_item = slots[current_slot].item
	highlight_slot(current_slot)
	GameManager.equipped_item = selected_item


func highlight_slot(index):
	for i in slots.size():
		slots[i].clear_highlight()
	slots[index].highlight()
