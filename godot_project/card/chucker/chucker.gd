extends Card

@export var move_vector: Vector2i = Vector2i.RIGHT

func move_and_chuck():
	assert(move_vector.x == 0 or move_vector.y == 0)  # for now this keeps things simple
	for step in int(move_vector.length()):
		var next_position = current_grid_position + move_vector.sign()
		if not game_board.is_inside_grid(next_position):
			move_vector *= -1
			next_position = current_grid_position + move_vector.sign()
			if not game_board.is_inside_grid(next_position):
				return
		if next_position in game_board.card_grid_spaces:
			game_board.move_multiple_simultaneously(
				{
					self: next_position,
					game_board.card_grid_spaces[next_position]: current_grid_position,
				}
			)
		else:
			set_grid_position(next_position)

func do_card_effect():
	move_and_chuck()


