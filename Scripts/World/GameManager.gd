extends Node2D

@export var start_scene : PackedScene


func _ready() -> void:
	SceneMagement.load_biome(start_scene);
