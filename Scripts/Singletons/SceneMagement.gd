extends Node

var current_biome: Node = null

func load_biome(scene: PackedScene) -> void:
	if current_biome:
		current_biome.queue_free()

	current_biome = scene.instantiate()
	get_tree().current_scene.add_child(current_biome)
