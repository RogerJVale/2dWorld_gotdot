extends Node
var player : CharacterBody2D
var current_biome: Node = null
var target_teleporter : Node2D = null;

func load_biome(biome_name: String) -> void:
	print("Loading biome: ", biome_name)

	# Build the path from the string
	var path := "res://Scenes/World/%s.tscn" % biome_name

	# Load the biome scene
	var biome_scene: PackedScene = load(path)
	if biome_scene == null:
		push_error("Biome not found at: " + path)
		return

	# Remove old biome
	if current_biome:
		current_biome.queue_free()

	# Instance new biome
	current_biome = biome_scene.instantiate()
	get_tree().current_scene.add_child(current_biome)

	target_teleporter = current_biome.get_node_or_null("TeleportArea")

	target_teleporter.position_player_on_arrival(player)

	if biome_name == "ForestBiome":
		GameManager.set_2D_Platform()
	else:
		GameManager.set_top_dpwn()
