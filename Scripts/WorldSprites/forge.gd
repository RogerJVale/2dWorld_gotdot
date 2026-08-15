extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GlobalSignals.show_mini_dialog.emit(
		"Press E to Craft",
		func():
			GlobalSignals.open_crafting_menu.emit(),
		self
			)

func _on_body_exited(body: Node2D) -> void:
	GlobalSignals.hide_mini_dialog.emit(self)
