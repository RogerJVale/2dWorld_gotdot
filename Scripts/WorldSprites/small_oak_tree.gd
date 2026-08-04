extends Sprite2D

func _ready() -> void:
	set_instance_shader_parameter("RandomStrength", randf_range(-15.0,15.0))
