extends PanelContainer
class_name RecipeUI
@onready var line_2d: Line2D = $Line2D

@export var recipe: Recipe
@onready var recipe_items: GridContainer = $RecipeItems

var panel_is_active = false
var ingredient_count = 0
var slots: Array[Slot]
func _ready() -> void:
	var sb := get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", sb)
	for child in recipe_items.get_children():
		if child is Slot:
			slots.append(child)
	if recipe:
		display_ingredients()

func hide_all_slots():
	Utils.hide_all_children(self)

func highlight():
	print("highlight")
	#(get_theme_stylebox("panel") as StyleBoxFlat).bg_color = Color(1,0,0,1)
	line_2d.hide()

func remove_highlight():
	#(get_theme_stylebox("panel") as StyleBoxFlat).bg_color = Color(0,0,0,0)
	print("remove highlight")
	line_2d.show()

func display_ingredients():

	# fill the input
	for d in recipe.ingredients:
		var data = d.get_ingredient()
		slots[ingredient_count].show()
		slots[ingredient_count].item = data.item
		slots[ingredient_count].set_amount(data.amount)
		ingredient_count += 1
	#fill the output
	slots[4].item = recipe.output

func get_recipe_slots():
	return slots
