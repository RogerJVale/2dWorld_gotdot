extends Node

@export var world_time: Node
@export var overlay: ColorRect
@export var lbl: Label
func _process(_delta):
	var t := GameManager.get_day_progress()
	lbl.text ="time " + GameManager.get_time_string()

	# Smooth brightness curve
	var brightness = clamp(lerp(0.0, 1.0, sin(t * PI)), 0.0, 1.0)

	# Night tint (bluish)
	var night_color := Color(0.2, 0.2, 0.4, 0.6)

	# Day tint (transparent)
	var day_color := Color(1, 1, 1, 0.0)

	overlay.color = night_color.lerp(day_color, brightness)
