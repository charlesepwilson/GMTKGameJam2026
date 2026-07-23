class_name GameBoard
extends Node2D

var total_grid_x_spaces: int = 5
var total_grid_y_spaces: int = 5

@onready var grid_visual = $GridVisual
@onready var grid_occupiers = $GridVisual/GridOccupiers
@onready var player_cards: PlayerCards = $PlayerCards
var card_grid_spaces: Dictionary[Vector2i, Card] = {}
var level_max_number: int = 5

signal turn_end()

func _on_move_button_pressed():
	end_turn()

func end_turn():
	turn_end.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# grid_visual.total_grid_x_spaces = total_grid_x_spaces
	# grid_visual.total_grid_y_spaces = total_grid_y_spaces
	# todo single definition of grid size


	for card in player_cards.get_children():
		if card is Card:
			turn_end.connect(card.on_turn_end_effect)
			for grid_square in grid_visual.grid_squares.get_children():
				if grid_square is GridSpace:
					grid_square.mouse_released.connect(card.grid_space_input_event)

func get_physical_position(grid_position: Vector2i) -> Vector2:
	return grid_visual.get_physical_position(grid_position)

func is_inside_grid(grid_position: Vector2i) -> bool:
	return grid_position.x >= 0 and grid_position.y >= 0 and grid_position.x < total_grid_x_spaces and grid_position.y < total_grid_y_spaces

func can_place_here(grid_position: Vector2i) -> bool:
	return is_inside_grid(grid_position) and grid_position not in card_grid_spaces

func physical_position_to_grid_position(physical_position: Vector2) -> Vector2i:
	return grid_visual.physical_position_to_grid_position(physical_position)

func _find_next_number_options(card: Card) -> Array[Card]:
	var options: Array[Card] = []
	for direction in [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]:
		var adjacent_card = card_grid_spaces.get(card.current_grid_position + direction)
		if adjacent_card == null:
			continue
		if adjacent_card is Card and adjacent_card.card_number == (card.card_number - 1):
			options.append(adjacent_card)
	return options

func _find_descending_chain(current_chain: Array[Card]):
	var last_card: Card = current_chain[-1]
	if last_card.card_number == 1:
		return current_chain
	var next_number_options: Array[Card] = _find_next_number_options(last_card)
	if len(next_number_options) == 0:
		return false
	for option in next_number_options:
		var new_chain = current_chain.duplicate()
		new_chain.append(option)
		var final_chain = _find_descending_chain(new_chain)
		if final_chain is Array:
			return final_chain
	return false


func check_victory():  # return array of cards or false
	var start_cards: Array[Card] = []
	for grid_pos in card_grid_spaces:
		var card: Card = card_grid_spaces[grid_pos]
		if card.card_number == level_max_number:
			start_cards.append(card)
	for card in start_cards:
		var chain = _find_descending_chain([card])
		if chain is Array:
			return chain
	return false


func _on_victory_check_pressed() -> void:
	print(check_victory())
