extends Card

const KNIGHT_JUMP: Vector2i = Vector2i.RIGHT + 2 * Vector2i.UP
const SIDE_KNIGHT_JUMP: Vector2i = Vector2i.UP + 2 * Vector2i.RIGHT

@export var jump_options: Array[Vector2i] = [
	KNIGHT_JUMP,
	SIDE_KNIGHT_JUMP,
	SIDE_KNIGHT_JUMP * Vector2i(1, -1),
	KNIGHT_JUMP * Vector2i(1, -1),
	KNIGHT_JUMP * -1,
	SIDE_KNIGHT_JUMP * -1,
	SIDE_KNIGHT_JUMP * Vector2i(-1, 1),
	KNIGHT_JUMP * Vector2i(-1, 1),
]

# var _current_index: int = 0  # todo use this to force behaviour to vary?

func jump():
	for option in jump_options:
		var target_position = current_grid_position + option
		if game_board.can_place_here(target_position):
			set_grid_position(target_position)
			return



func do_card_effect():
	jump()
