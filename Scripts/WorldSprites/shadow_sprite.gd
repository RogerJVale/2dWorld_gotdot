@tool
extends Node2D


@onready var Sprite: Sprite2D = $".."

@onready var shadow_sprite: Sprite2D = $"."

func _ready():
	# Force a grey shadow using a shader override
	var shader := Shader.new()
	shader.code = """
	    shader_type canvas_item;

	    void fragment() {
	        vec4 tex = texture(TEXTURE, UV);
	        float grey = (tex.r + tex.g + tex.b) / 3.0;
	        COLOR = vec4(grey * 0.4, grey * 0.4, grey * 0.4, tex.a * 0.6);
	    }
	"""

	var mat := ShaderMaterial.new()
	mat.shader = shader
	self.material = mat


	# Make it grey + semi-transparent
	modulate = Color(0.2, 0.2, 0.2, 0.5)

	# Squash the shadow
	scale = Vector2(1.0, 0.3)

	# Offset downward
	position = Vector2(0, 12)

	# Slight angle
	rotation = deg_to_rad(10)

	# Optional skew (for that stretched look)
	var t := Transform2D()
	t.x = Vector2(1, 0.3)  # horizontal skew
	t.y = Vector2(0, 1)    # normal vertical
	transform = t
