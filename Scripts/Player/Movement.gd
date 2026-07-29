extends CharacterBody2D

#ref to animated sprite
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#ref
@export var speed: float = 200.0

var is_moving:bool = false;

var last_direction: Vector2 = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	process_movement()
	process_animation()
	move_and_slide()

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * speed
		last_direction = direction
	else:
		velocity = Vector2.ZERO

func process_animation():
	if velocity != Vector2.ZERO:
		play_animation("walk", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix : String, dir: Vector2) -> void:
	if dir.x> 0:
		anim.play(prefix + "_right")
	elif dir.x < 0:
		anim.play(prefix + "_left")
	elif dir.y < 0:
		anim.play(prefix + "_up")
	elif dir.y > 0:
		anim.play(prefix + "_down")
