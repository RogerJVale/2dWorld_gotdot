extends Node2D


@export var start_scene : PackedScene

var _player: Movement

func _ready() -> void:
	pass

func register_player(player: CharacterBody2D):
	_player = player
	SceneMagement.load_biome("GrassBiome");

func set_2D_Platform():
	_player.enable_platformer_controls()



func set_top_dpwn():
	_player.enable_topdownControls()
