extends Node

@export var pop_height := 40
@export var pop_duration := 0.5
@export var pause_duration := 0.00001
@export var drop_duration := 0.5
@export var start_delay := 0.2

func _ready():
	await get_tree().create_timer(start_delay).timeout
	start()

func start():
	var host := get_parent()
	var original_pos = host.position

	# POP UP
	var pop := create_tween().bind_node(host)
	pop.set_trans(Tween.TRANS_BACK)
	pop.set_ease(Tween.EASE_OUT)
	pop.tween_property(host, "position", original_pos + Vector2(0, -pop_height), pop_duration)
	await pop.finished

	# PAUSE
	await get_tree().create_timer(pause_duration).timeout

	# DROP DOWN
	var drop := create_tween().bind_node(host)
	drop.set_trans(Tween.TRANS_SINE)
	drop.set_ease(Tween.EASE_IN)
	drop.tween_property(host, "position", original_pos, drop_duration)
	await drop.finished

	# FINAL LEFT/RIGHT BOUNCE (NO RETURN)
	var bounce_offset := 10
	var direction = sign(randf() - 0.5)  # random -1 or +1

	var final_pos = original_pos + Vector2(bounce_offset * direction, 0)

	var bounce := create_tween().bind_node(host)
	bounce.set_trans(Tween.TRANS_SINE)
	bounce.set_ease(Tween.EASE_OUT)
	bounce.tween_property(host, "position", final_pos, 0.08)
	await bounce.finished

	# Update original_pos so future logic knows the new resting spot
	host.position = final_pos
