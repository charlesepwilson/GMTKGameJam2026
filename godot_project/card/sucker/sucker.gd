extends Card


@export var suck_strength: int = 1
@export var suck_range: int = 2

func suck():
	for direction in [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]:
		var target_position = current_grid_position + suck_range * direction.sign()
		var target_card = game_board.card_grid_spaces.get(target_position)
		if target_card is Card:
			target_card.push(direction * suck_strength * -1)



func do_card_effect():
	suck()

func _describe_effect() -> String:
	return "Pulls anything in range in a straight line towards them."
