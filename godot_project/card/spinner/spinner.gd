
extends Card

@export var spin_targets: Array[Vector2i] = [
	Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
]
@export var num_quarter_turns: int = 1  # negative for anticlockwise

func _rotate_vector(v: Vector2i) -> Vector2i:
	return Vector2i(-v.y, v.x)
func _unrotate_vector(v: Vector2i) -> Vector2i:
	return Vector2i(v.y, -v.x)


func spin():
	var move_requests: Dictionary[Card, Vector2i] = {}
	for target in spin_targets:
		var target_pos: Vector2i = current_grid_position + target
		var target_card = game_board.card_grid_spaces.get(target_pos)
		if target_card is Card:
			var move_to = target
			for turn in abs(num_quarter_turns):
				if num_quarter_turns > 0:
					move_to = _rotate_vector(move_to)
				else:
					move_to = _unrotate_vector(move_to)
			move_requests[target_card] = move_to + current_grid_position
	game_board.move_multiple_simultaneously(move_requests)




func do_card_effect():
	spin()


func _describe_effect() -> String:
	return "Rotates everything adjacent a quarter turn clockwise"
