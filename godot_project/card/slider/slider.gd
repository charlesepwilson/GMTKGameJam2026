extends Card

@export var move_vector: Vector2i = Vector2i.RIGHT

func slide():
	assert(move_vector.x == 0 or move_vector.y == 0)  # for now this keeps things simple
	for step in int(move_vector.length()):
		var next_position = current_grid_position + move_vector.sign()
		if next_position in game_board.card_grid_spaces:
			return
		if not game_board.is_inside_grid(next_position):
			return
		set_grid_position(next_position)


func do_card_effect():
	slide()

func _describe_effect() -> String:
	return "Moves along in a fixed direction. Refuses to turn around."

func set_icon_direction():
	_set_icon_direction(move_vector)

func _ready() -> void:
	super._ready()
	set_icon_direction()
