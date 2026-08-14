extends CanvasLayer
class_name MiniDialog
@export var background_texture : Texture2D

var _owner = null
var callback: Callable = Callable()

func _ready() -> void:
	$Panel.visible = false;
	GlobalSignals.show_mini_dialog.connect(show_dialog)
	GlobalSignals.hide_mini_dialog.connect(hide_dialog)

func show_dialog(text: String, on_confirm: Callable, caller) -> void:
	if _owner != null and _owner != caller:
		return
	_owner = caller
	print("Called show dialog")
	$Panel.visible = true
	$Panel/Label.text = text
	callback = on_confirm
	set_process_input(true)

func hide_dialog(caller):
	if caller != _owner:
		return
	_owner = null
	$Panel.visible = false
	print("hide_dialog")
	Utils.print_caller()

func _input(event):
	if $Panel.visible and event.is_action_pressed("interact"):
		print("e pressed")
		$Panel.visible = false
		set_process_input(false)

		if callback.is_valid():
			callback.call()
func _sync():
	var label := $Panel/Label
	var panel := $Panel

	var text_size = label.get_combined_minimum_size()

	panel.size = text_size + Vector2(40, 40)
	label.position = (panel.size - text_size) * 0.5
