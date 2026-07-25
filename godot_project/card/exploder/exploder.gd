extends Card

@export var explode_strength: int = 1
# @export var explode_range: int = 1

func explode():
	for direction in [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]:
		var target_position = current_grid_position + direction.sign()
		var target_card = game_board.card_grid_spaces.get(target_position)
		if target_card is Card:
			target_card.push(direction * explode_strength)



func do_card_effect():
	explode()

func _describe_effect() -> String:
	return "Pushes everything adjacent away"
