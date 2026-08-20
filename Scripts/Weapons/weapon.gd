extends Node2D

@export var animation_name: String = "default"


func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(_on_animated_sprite_2d_animation_finished)




func _on_animated_sprite_2d_animation_finished() -> void:
	#print("Animation Finished")
	visible = false
	$"../..".visible = false

func play_anim():
	visible = true
	$AnimatedSprite2D.play(animation_name)
	$Slash.play("slash_l")
