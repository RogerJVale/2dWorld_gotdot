extends CanvasLayer

@export var background_texture : Texture2D

var callback: Callable = Callable()

func _ready() -> void:
	$Panel.visible = false;
	$Panel/Label.resized.connect(_sync)
	return
	var sb := StyleBoxTexture.new()
	sb.texture = background_texture
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.set_expand_margin(30,30)  # optional padding

	$Panel.add_theme_stylebox_override("panel", sb)



func show_dialog(text: String, on_confirm: Callable) -> void:
	print("Called show dialog")
	$Panel.visible = true
	$Panel/Label.text = text
	callback = on_confirm
	set_process_input(true)

func hide_dialog():
	$Panel.visible = false


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

	panel.size = label.size + Vector2(40,40)

	# Center the label inside the panel
	label.position = (panel.size - label.size) * 0.5
