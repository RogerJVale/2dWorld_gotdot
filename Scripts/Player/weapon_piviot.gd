@tool
extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var weapon_sprite: Sprite2D = $Sprite2D

@export var facing_left_position: Vector2
@export var facing_right_position: Vector2
@export var facing_up_position: Vector2
@export var facing_down_position: Vector2

@export var start_angle: float = -90.0
@export var end_angle: float = 45.0
@export var swing_time: float = 0.2
@export var return_time: float = 0.15

@export var flip: bool = false

@export var swing: bool:
	set(value):
		start_swing(Vector2(0,0))

var t := 0.0
var swinging := false
var returning := false

var s_angle := 0.0
var e_angle := 0.0

func _ready() -> void:
	GlobalSignals.player_swapped_weapon.connect(_on_swap_weapon)
func start_swing(dir: Vector2):
	show()
	t = 0.0
	swinging = true
	returning = false

	s_angle = start_angle

	# Decide primary direction
	if abs(dir.x) > abs(dir.y): # horizontal
		if dir.x < 0: # left
			position = facing_left_position
			var original_end := end_angle
			e_angle = s_angle - (original_end - s_angle)

			z_index = -1
			animated_sprite_2d.play("idle_left")
			weapon_sprite.flip_h = true
		else: # right
			position = facing_right_position
			e_angle = end_angle

			z_index = 0
			animated_sprite_2d.play("idle_right")
			weapon_sprite.flip_h = false

	else: # vertical
		if dir.y < 0: # up
			position = facing_up_position
			var original_end := end_angle
			e_angle = s_angle - (original_end - s_angle)

			z_index = -1
			animated_sprite_2d.play("idle_up")
			weapon_sprite.flip_h = true
		else: # down
			print("down")
			position = facing_down_position

			# DOWN swings clockwise → same as RIGHT
			e_angle = end_angle

			z_index = 0
			animated_sprite_2d.play("idle_down")
			weapon_sprite.flip_h = false

	rotation_degrees = s_angle

func _process(delta):
	if swinging:
		t += delta
		var alpha = clamp(t / swing_time, 0.0, 1.0)
		rotation_degrees = lerp(s_angle, e_angle, alpha)

		if alpha >= 1.0:
			swinging = false
			returning = true
			t = 0.0

	elif returning:
		t += delta
		var alpha = clamp(t / return_time, 0.0, 1.0)
		rotation_degrees = lerp(e_angle, s_angle, alpha)

		if alpha >= 1.0:
			returning = false

		GlobalSignals.player_weapon_swing_completed.emit()
		GlobalSignals.hide_marker.emit()
		hide()

func _on_swap_weapon(item: Item):
	if item != null:
		weapon_sprite.texture = item.texture
