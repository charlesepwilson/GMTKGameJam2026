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

var _visits: Dictionary[Vector2i, int] = {}

func jump():
	if current_grid_position not in _visits:
		_visits[current_grid_position] = 1
	var actual_options: Array[Vector2i] = []
	for option in jump_options:
		var target_position = current_grid_position + option
		if game_board.can_place_here(target_position):
			actual_options.append(target_position)
	if not actual_options:
		return
	var filtered_visits: Dictionary[Vector2i, int] = {}
	for actual_option in actual_options:
		if actual_option in _visits:
			filtered_visits[actual_option] = _visits[actual_option]
		else:
			filtered_visits[actual_option] = 0
	var minimum_viable_visits: int = filtered_visits.values().min()
	for target_position in actual_options:
		if filtered_visits[target_position] == minimum_viable_visits:
			set_grid_position(target_position)
			if target_position in _visits:
				_visits[target_position] += 1
			else:
				_visits[target_position] = 1
			return



func do_card_effect():
	jump()


func save_state() -> Dictionary:
	var dict = super.save_state()
	dict["_visits"] = _visits.duplicate()
	return dict

func load_state(state_dict: Dictionary):
	super.load_state(state_dict)
	_visits = state_dict["_visits"]

func _describe_effect() -> String:
	return "Jumps around in an 'L' shape. Searches for a target in a clockwise pattern, but avoids locations they've already been to."
