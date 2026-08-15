class_name Movement
extends CharacterBody2D

#ref to animated sprite
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var mini_dialog: CanvasLayer = $"../MiniDialog"
@onready var selection_wheel: Control = $"../CanvasLayer/SelectionWheel"

@export var marker: FloorMarker
#Movement Speed
@export var speed: float = 150.0
# topdown vars
var is_td : bool
var is_moving:bool = false;
var is_grounded : bool
var is_attacking = false;
var last_direction: Vector2 = Vector2.RIGHT
var direction: Vector2
var world_size: Vector2 = Vector2.ZERO
# platform vars
const jump_height: float = -350
var _gravity: float = 980
const max_gravity: float = 14.5

const max_speed: float = 50
const acceleration : float = 8
const friction: float = 10

#
# thisis the cell that will be effected by tools
var target_cell: Vector2i

func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	call_deferred("register_player")

func register_player()->void:
	SceneMagement.player = self
	GameManager.register_player(self)
	$"Camera2D".setup()
	world_size = Utils.calculate_world_size(GameManager.infront_layer)

func _process(delta: float) -> void:
	######################
	# handle the tool input
	######################
	if GameManager.game_state == GameStates.GameState.PLAY:
		if Input.is_action_just_pressed("attack2"):
			if GameManager.equipped_item == null:
				mini_dialog.show_dialog("No Item Equipped", func(): mini_dialog.hide_dialog(self),self )
				return
			#Debug
			#var tile_data = GameManager.getTileData(position, "Ground")
			#print("Player: tiledata = ", tile_data)
			#Debug end
			if GameManager.equipped_item.name == "Axe":
				marker.show_marker("Axe")
			elif GameManager.equipped_item.name == "Shovel":
				marker.show_marker("Shovel")
				GameManager.change_tile(target_cell)
			elif GameManager.equipped_item.name == "Watering Can":
				marker.show_marker("WateringCan")
			elif GameManager.equipped_item.name == "pick":
				marker.show_marker("Pick")
	if GameManager.game_state == GameStates.GameState.BUILDING:
		marker.show_marker("Chest")
		if Input.is_action_just_pressed("attack2"):
			GlobalSignals.try_place_object.emit(marker.position, preload("res://Scripts/Inventory/Items/chest.tres"))

		if Input.is_action_just_released("attack2"):
			print("Should place chest !")


func _physics_process(delta: float) -> void:

	process_movement()
	process_animation()
	#if we are side scrolling
	if !is_td:
		process_jump()
		process_gravity(delta)

	move_and_slide()

	# Snap only when player stops
	if direction == Vector2.ZERO and velocity == Vector2.ZERO:
		snap_player_to_tile()


#region  Movement
func process_movement() -> void:
	if GameManager.game_state == GameStates.GameState.PLAY \
	or GameManager.game_state == GameStates.GameState.BUILDING:
		if is_td:
			# Top-down movement
			direction = Input.get_vector("left", "right", "up", "down")
			velocity = direction * speed

			if direction != Vector2.ZERO:
				last_direction = direction
				check_for_drop()
				GameManager.check_enviorment()
			#display_tile_data()
			_clamp_player()
		else:
			# Platformer movement (NO up/down input)
			var x_input := Input.get_action_strength("right") - Input.get_action_strength("left")
			velocity.x = x_input * speed

			# Only update last_direction when actually moving
			if x_input != 0:
				last_direction.x = x_input

func _clamp_player():
	var min_x = 0
	var max_x = world_size.x
	var min_y = 0
	var max_y = world_size.y
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)

func process_jump():
	if Input.is_action_just_pressed('jump'):
		velocity.y = jump_height

func process_gravity(delta: float):
	#var gravity = lerp(gravity,max_gravity, 12.0 * delta)
	velocity.y += _gravity * delta

func process_animation():
	if is_attacking: return
	if velocity != Vector2.ZERO:
		play_animation("walk", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix : String, dir: Vector2) -> void:
	if dir.x> 0:
		anim.play(prefix + "_right")
	elif dir.x < 0:
		anim.play(prefix + "_left")
	elif dir.y < 0 && is_td:
		anim.play(prefix + "_up")
	elif dir.y > 0 && is_td:
		anim.play(prefix + "_down")

func play_attack_animation(prefix: String):
	is_attacking = true
	print("playing attack animation")
	var dir = last_direction
	if dir.x> 0:
		anim.play(prefix + "_right")
	elif dir.x < 0:
		anim.play(prefix + "_left")
	elif dir.y < 0 && is_td:
		anim.play(prefix + "_up")
	elif dir.y > 0 && is_td:
		anim.play(prefix + "_down")

func _on_animated_sprite_2d_animation_finished():
	if is_attacking:
		is_attacking = false
#endregion

func check_for_drop():
	GameManager.check_for_drop_nearby(position)

func enable_platformer_controls():
	print("Seeting up for platformer")

	is_td = false

func enable_topdownControls():
	print("Seeting up for topdown")

	is_td = true

#func display_tile_data():
	#if GameManager.getTileData(position):
		#var data: String = GameManager.getTileData(position)
		##print ("Tile data " + data)

func snap_player_to_tile():

	var tile_layer = SceneMagement.ground_layer
	if tile_layer == null:
		return
	# Use last_direction to choose the tile in front of the player
	var target_pos = global_position

	# Convert world → tile coordinate
	var cell: Vector2i = tile_layer.local_to_map(tile_layer.to_local(target_pos))

	# Convert tile → world position
	var snapped_pos: Vector2 = tile_layer.map_to_local(cell)
	snapped_pos = tile_layer.to_global(snapped_pos)

	# Snap to tile center (critical!)
	#snapped_pos += tile_layer.tile_set.tile_size / 2.0

	# Apply snap
	global_position = snapped_pos
