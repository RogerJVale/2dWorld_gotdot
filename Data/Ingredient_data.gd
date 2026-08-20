extends Resource
class_name Ingredient

@export var item: Item
@export var amount: int


func get_ingredient():
	return {"item": item, "amount": amount}
