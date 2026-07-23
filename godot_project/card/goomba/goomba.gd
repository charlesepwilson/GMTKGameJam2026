extends Card

@export var move_vector: Vector2i = Vector2i.RIGHT

func goomb():
	assert(move_vector.x == 0 or move_vector.y == 0)  # for now this keeps things simple
	for step in int(move_vector.length()):
		var next_position = current_grid_position + move_vector.sign()
		if not game_board.can_place_here(next_position):
			move_vector *= -1
			next_position = current_grid_position + move_vector.sign()
			if not game_board.can_place_here(next_position):
				return
		set_grid_position(next_position)


func do_card_effect():
	goomb()
