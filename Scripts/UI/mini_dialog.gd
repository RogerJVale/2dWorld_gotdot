extends CanvasLayer
class_name MiniDialog

@export var background_texture : Texture2D
@onready var panel: PanelContainer = $Panel
@onready var label: Label = $Panel/Label

var _owner = null
var callback: Callable = Callable()

func _ready() -> void:
	panel.visible = false;
	GlobalSignals.show_mini_dialog.connect(show_dialog)
	GlobalSignals.hide_mini_dialog.connect(hide_dialog)

func show_dialog(text: String, on_confirm: Callable, caller) -> void:
	if _owner != null and _owner != caller:
		return
	_owner = caller
	print("Called show dialog")
	panel.visible = true
	label.text = text
	callback = on_confirm
	set_process_input(true)
	var canvas_pos: Vector2 = caller.get_global_transform_with_canvas().origin
	panel.position = canvas_pos
	panel.reset_size()



func hide_dialog(caller):
	if caller != _owner:
		return
	_owner = null
	panel.visible = false
	print("hide_dialog")
	Utils.print_caller()

func _input(event):
	if panel.visible and event.is_action_pressed("interact"):
		print("e pressed")
		panel.visible = false
		set_process_input(false)

		if callback.is_valid():
			callback.call()
