extends Node

@export var inventory : Inventory
@export var recipe_ui : RecipeUI


@onready var slots : = []
@onready var recipe_holder = $VBoxContainer/Panel/ScrollContainer/RecipeHolderVboxContainer

var current_slot := 0
@export var selected_item: Item = null

var rows : Array[RecipeUI] = []
var active_row








func _process(_delta):
	handle_navigation_input()
#region Navigation

func handle_navigation_input():
	if GameManager.game_state == GameStates.GameState.CRAFTING:
		if Input.is_action_just_pressed("nav_down"):
			current_slot = (current_slot + 1) % rows.size()
			update_highlight()

		if Input.is_action_just_pressed("nav_up"):
			current_slot = (current_slot - 1 + rows.size()) % rows.size()
			update_highlight()
func keep_row_in_view(row: RecipeUI):
	var scroll := $VBoxContainer/Panel/ScrollContainer
	scroll.ensure_control_visible(row)

func update_highlight():
	unhighlight_all()
	rows[current_slot].highlight()
	keep_row_in_view(rows[current_slot])
func unhighlight_all():

	for i in rows.size():
		rows[i].remove_highlight()
#endregion

func build_avaliable_crafting_list(avaliable_recipes:Array[Recipe]):
	rows.clear()
	Utils.remove_all_children(recipe_holder)
	var counter = 0
	for recipe in avaliable_recipes:
		var obj:RecipeUI = preload("res://Scenes/UI/recipe_ui.tscn").instantiate()
		recipe_holder.add_child(obj)
		rows.append(obj)
		if can_craft(obj.recipe):
			print("can craft")
			rows[counter].highlight()
		else:
			print("can't craft")
			rows[counter].remove_highlight()

		counter += 1


func can_craft(recipe: Recipe) -> bool:
	for ing in recipe.ingredients:
		var stock = inventory.get_amount(ing.item)
		print(ing.item.name, " stock " , stock , " - ", ing.amount )
		if stock < ing.amount:
			return false
	return true

func craft(recipe: Recipe) -> bool:
	if not can_craft(recipe):
		return false

	# Remove ingredients
	for ing in recipe.ingredients:
		inventory.remove_item(ing.item, ing.amount)

	# Add output
	inventory.add_item(recipe.output, recipe.output_amount)

	return true
