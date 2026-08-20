extends ScrollContainer

func _input(event: InputEvent) -> void:

	if GameManager.game_state == GameStates.GameState.CRAFTING:
		if Input.is_action_pressed("scroll_up"):
			set_v_scroll(get_v_scroll() + 100)

		if Input.is_action_pressed("scroll_down"):
			set_v_scroll(get_v_scroll() - 100)
