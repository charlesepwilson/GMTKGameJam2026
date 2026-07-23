class_name GameBoard
extends Node2D

var player_can_interact: bool = true
var gap_between_movements: float = 1.0
@export var level_number: int = 0

@onready var victory_popup: VictoryPopup = $VictoryPopup

@export var total_grid_x_spaces: int = 5
@export var total_grid_y_spaces: int = 5
@export var level_max_number: int = 6

@onready var grid_visual = $GridVisual
@onready var grid_occupiers = $GridVisual/GridOccupiers
@onready var player_cards: PlayerCards = $PlayerCards
var card_grid_spaces: Dictionary[Vector2i, Card] = {}

signal player_interaction_stop()
signal player_interaction_start()

signal turn_end(card_number: int)
signal card_played(card_number: int)

func _on_player_interaction_stop():
	player_can_interact = false
	for button in find_children("*", "Button", false):
		button.disabled = true

func _on_player_interaction_start():
	var victory: bool = perform_victory_check()
	if not victory:
		player_can_interact = true
		for button in find_children("*", "Button", false):
			button.disabled = false

func _global_on_card_play():
	player_interaction_stop.emit()
	var numbers_present = _get_numbers_present(Card.EFFECT_TRIGGER.ON_CARD_PLAYED)
	for card_number in range(level_max_number, 0, -1):
		if card_number in numbers_present:
			card_played.emit(card_number)
			await get_tree().create_timer(gap_between_movements).timeout
	player_interaction_start.emit()

func _on_move_button_pressed():
	if not player_can_interact:
		return
	end_turn()

func _get_numbers_present(effect_filter: Card.EFFECT_TRIGGER) -> Array[int]:
	var numbers_present: Array[int] = []
	for card in card_grid_spaces.values():
		if effect_filter in card.effect_triggers:
			numbers_present.append(card.card_number)
	return numbers_present

func end_turn():
	player_interaction_stop.emit()

	var numbers_present = _get_numbers_present(Card.EFFECT_TRIGGER.ON_TURN_END)
	for card_number in range(level_max_number, 0, -1):
		if card_number in numbers_present:
			turn_end.emit(card_number)
			await get_tree().create_timer(gap_between_movements).timeout
	player_interaction_start.emit()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	victory_popup.level_number = level_number
	player_interaction_start.connect(_on_player_interaction_start)
	player_interaction_stop.connect(_on_player_interaction_stop)

	grid_visual.total_grid_x_spaces = total_grid_x_spaces
	grid_visual.total_grid_y_spaces = total_grid_y_spaces
	grid_visual.construct_grid()
	player_cards.card_played.connect(_global_on_card_play)
	player_cards.card_drawn.connect(_animate_door)

	for card in player_cards.get_children():
		if card is Card:
			turn_end.connect(card.on_turn_end_effect)
			card_played.connect(card.on_card_played_effect)
			for grid_square in grid_visual.grid_squares.get_children():
				if grid_square is GridSpace:
					grid_square.mouse_released.connect(card.grid_space_input_event)
					grid_square.area2d.mouse_entered.connect(card.grid_space_mouse_entered)
					grid_square.area2d.mouse_exited.connect(card.grid_space_mouse_exit)


func get_physical_position(grid_position: Vector2i) -> Vector2:
	return grid_visual.get_physical_position(grid_position)

func is_inside_grid(grid_position: Vector2i) -> bool:
	return grid_position.x >= 0 and grid_position.y >= 0 and grid_position.x < total_grid_x_spaces and grid_position.y < total_grid_y_spaces

func can_place_here(grid_position: Vector2i) -> bool:
	return is_inside_grid(grid_position) and grid_position not in card_grid_spaces

func physical_position_to_grid_position(physical_position: Vector2) -> Vector2i:
	return grid_visual.physical_position_to_grid_position(physical_position)


func move_multiple_simultaneously(move_requests: Dictionary[Card, Vector2i]):
	var all_targets = move_requests.values()
	var target_set = {}
	for t in all_targets:
		target_set[t] = true
	if len(target_set) < len(move_requests):
		# multiple requests to move to same place
		return

	for card in move_requests:
		card_grid_spaces.erase(card.current_grid_position)
	var move_is_valid: bool = true
	for card in move_requests:
		if not can_place_here(move_requests[card]):
			move_is_valid = false
			break

	if not move_is_valid:
		for card in move_requests:
			card_grid_spaces[card.current_grid_position] = card
	else:
		for card in move_requests:
			card.set_grid_position(move_requests[card])

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


func _check_victory():  # return array of cards or false
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

func perform_victory_check() -> bool:
	var victory = _check_victory()
	if victory:
		player_interaction_stop.emit()
		victory_popup.visible = true
		return true
	else:
		return false

@onready var open_door: Sprite2D = $Door/Open
@onready var door_sfx: AudioStreamPlayer2D = $Door/AudioStreamPlayer2D

func _animate_door():
	door_sfx.play(0.18)
	open_door.visible = true
	await get_tree().create_timer(0.3).timeout
	open_door.visible = false
