extends Area2D

@export var target_biome: String

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var dialog = get_tree().current_scene.get_node("MiniDialog")
		dialog.show_dialog(
			"Press E to enter " + target_biome,
			func(): SceneMagement.call_deferred("load_biome", target_biome)
		)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var dialog = get_tree().current_scene.get_node("MiniDialog")
		dialog.hide_dialog()

func position_player_on_arrival(player: CharacterBody2D):
	print(player.name)
	player.position = position
