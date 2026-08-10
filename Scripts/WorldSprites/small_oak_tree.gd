extends Sprite2D

func _ready() -> void:
	#set_instance_shader_parameter("RandomStrength", randf_range(-15.0,15.0))
	var r = randf_range(-15.0, 15.0)
	self.modulate = Color(1, 1, 1, (r + 15.0) / 30.0)
