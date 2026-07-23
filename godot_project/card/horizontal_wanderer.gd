extends Card


func on_turn_end_effect():
	if card_mode == CARD_MODE.BOARD:
		slide(Vector2i.RIGHT)
