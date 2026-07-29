extends Area2D
@export var scene: PackedScene
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("entered doorway")
		SceneMagement.load_biome(scene)
