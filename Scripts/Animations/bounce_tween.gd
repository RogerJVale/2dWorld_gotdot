extends Node

@onready var host_sprite

@export var drop_height = 20
@export var start_at_top = false
@export var single_use = true

const TWEEN_DURATION = 0.1
const RECOVERY_FACTOR = 0.5

signal tween_completed

func _ready() -> void:
	var host = get_parent()
	if host.has_node("Sprite"):
		host_sprite = host.get_node("Sprite")
	elif host.has_node("AnimatedSprite"):
		host_sprite = host.get_node("AnimatedSprite")




func start(sprite = null):

	if sprite:
		host_sprite = sprite

	if start_at_top:
		var drop_tween : Tween = drop_down(drop_height)
		await drop_tween.finished
		drop_tween.queue_free()

	var bounce_height = drop_height * RECOVERY_FACTOR

	while bounce_height > 1:

		# bounce up
		var bounce_tween: Tween = bounce_up(bounce_height)
		await bounce_tween.finished
		bounce_tween.queue_free()

		# drop down
		var drop_tween : Tween = drop_down(bounce_height)
		await drop_tween.finished
		drop_tween.queue_free()

		bounce_height *= RECOVERY_FACTOR

	emit_signal("tween_completed")

	if single_use:
		queue_free()


func bounce_up(height):
	var y_end = -height
	var tween := create_tween().bind_node(self)
	tween.tween_property(self, "position:y", y_end, TWEEN_DURATION)
	return tween


func drop_down(height):
	var y_end = 0  # drop back to original position
	var tween := create_tween().bind_node(self)
	tween.tween_property(self, "position:y", y_end, TWEEN_DURATION)
	return tween
