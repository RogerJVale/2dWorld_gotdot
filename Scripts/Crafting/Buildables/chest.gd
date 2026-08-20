extends Area2D

@export var chest_id: String

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	GlobalSignals.open_chest.connect(open_chest)
	GlobalSignals.close_chest.connect(_close_chest)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GlobalSignals.show_mini_dialog.emit(
		"Press E to Open",
		func():
			GlobalSignals.open_chest.emit(self),
		self
			)

func _on_body_exited(_body: Node2D) -> void:
	GlobalSignals.hide_mini_dialog.emit(self)


func open_chest(caller):
	if caller == self:

		GlobalSignals.open_chest_inventory.emit(chest_id)

func _close_chest():

	print("Close chest")

func set_id(id: String):
	chest_id = id
