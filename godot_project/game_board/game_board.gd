class_name GameBoard
extends Node2D

var player_can_interact: bool = true
var gap_between_movements: float = 1.0
@export var level_number: int = 0

@onready var victory_popup: VictoryPopup = %VictoryPopup
@onready var failure_popup: VictoryPopup = %FailurePopup

@export var total_grid_x_spaces: int = 5
@export var total_grid_y_spaces: int = 5
var level_max_number: int

@onready var grid_visual = $GridVisual
@onready var grid_occupiers = $GridVisual/GridOccupiers
@onready var player_cards: PlayerCards = $PlayerCards
var card_grid_spaces: Dictionary[Vector2i, Card] = {}

@onready var dj_countdown_sfx: AudioStreamPlayer = $DJDeck/DJCountDownSFX

var dj_countdown_effect_files: Dictionary[int, AudioStream] = {
	1: preload("res://audio/1.mp3"),
	2: preload("res://audio/2.mp3"),
	3: preload("res://audio/3.mp3"),
	4: preload("res://audio/4.mp3"),
	5: preload("res://audio/5.mp3"),
	6: preload("res://audio/6.mp3"),
	7: preload("res://audio/7.mp3"),
	8: preload("res://audio/8.mp3"),
	9: preload("res://audio/9.mp3"),
	10: preload("res://audio/10.mp3"),
}

signal player_interaction_stop()
signal player_interaction_start()

signal turn_end(card_number: int)
signal card_played(card_number: int)

func _on_player_interaction_stop():
	player_can_interact = false
	for button in find_children("*", "Button"):
		button.disabled = true

func _on_player_interaction_start():
	save_game_state()
	player_can_interact = true
	for button in find_children("*", "Button"):
		button.disabled = false

func get_timer(t: float):
	return get_tree().create_timer(t / Settings.game_speed)

func _global_on_card_play():
	player_interaction_stop.emit()
	var numbers_present = _get_numbers_present(Card.EFFECT_TRIGGER.ON_CARD_PLAYED)
	for card_number in range(level_max_number, 0, -1):
		if card_number in numbers_present:
			play_dj_number(card_number)
			await get_timer(gap_between_movements).timeout
			card_played.emit(card_number)
			await get_timer(gap_between_movements).timeout
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
			play_dj_number(card_number)
			await get_timer(gap_between_movements).timeout
			turn_end.emit(card_number)
			await get_timer(gap_between_movements).timeout

	perform_victory_check()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	victory_popup.level_number = level_number
	failure_popup.level_number = level_number
	player_interaction_start.connect(_on_player_interaction_start)
	player_interaction_stop.connect(_on_player_interaction_stop)

	grid_visual.total_grid_x_spaces = total_grid_x_spaces
	grid_visual.total_grid_y_spaces = total_grid_y_spaces
	grid_visual.construct_grid()
	player_cards.card_played.connect(_global_on_card_play)
	player_cards.card_drawn.connect(_animate_door)
	player_cards.initial_hand_fill.connect(func(): player_interaction_start.emit())
	# player_cards.card_drawn.connect(save_game_state)

	for card in player_cards.get_children():
		if card is Card:
			turn_end.connect(card.on_turn_end_effect)
			card_played.connect(card.on_card_played_effect)
			for grid_square in grid_visual.grid_squares.get_children():
				if grid_square is GridSpace:
					grid_square.mouse_released.connect(card.grid_space_input_event)
					grid_square.area2d.mouse_entered.connect(card.grid_space_mouse_entered)
					grid_square.area2d.mouse_exited.connect(card.grid_space_mouse_exit)
	# save_game_state()
	player_interaction_stop.emit()
	var all_numbers: Array[int] = []
	for card in player_cards.draw_pile:
		all_numbers.append(card.card_number)
	level_max_number = all_numbers.max()


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

func play_dj_number(number: int):
	dj_countdown_sfx.stream = dj_countdown_effect_files[number]
	dj_countdown_sfx.pitch_scale = pow(Settings.game_speed / Settings.base_speed, 0.5)
	dj_countdown_sfx.play()

	_play_orch_hit(number)

@onready var orchestra_hit_sfx: AudioStreamPlayer = $DJDeck/OrchestraHitSFX

func _play_orch_hit(number: int):
	orchestra_hit_sfx.stop()
	var pitch_effect: AudioEffect = AudioServer.get_bus_effect(
		AudioServer.get_bus_index("PitchShift"),
		0
	) as AudioEffectPitchShift
	pitch_effect.pitch_scale = log(8.0 - (number/2.0))
	orchestra_hit_sfx.play()


func _animate_victory(victory_chain: Array[Card]):
	for card in victory_chain:
		play_dj_number(card.card_number)
		card.animate()
		await get_timer(gap_between_movements).timeout

func _activate_popups(victory):
	$UI/Control.visible = true
	for button in $UI/Control.find_children("*", "Button"):
		button.disabled = false
	if victory:
		victory_popup.visible = true
	else:
		failure_popup.visible = true

func perform_victory_check():
	var victory = _check_victory()
	if victory:
		await _animate_victory(victory)
	_activate_popups(victory)

@onready var open_door: Sprite2D = $Door/Open
@onready var door_sfx: AudioStreamPlayer2D = $Door/AudioStreamPlayer2D

func _animate_door():
	door_sfx.play(0.18)
	open_door.visible = true
	await get_timer(0.3).timeout
	open_door.visible = false


var _game_state_history: Array[GameState] = []

func save_game_state():
	var state = GameState.save(self)
	if _game_state_history:
		var previous_state = _game_state_history[-1]
		if previous_state.equals(state):
			return
	_game_state_history.append(state)

func restore_game_state(state: GameState):
	state.load(self)

func undo():
	if not _game_state_history:
		return
	var current_state: GameState = GameState.save(self)
	var history_length: int = len(_game_state_history)
	for i in history_length:
		var last_state: GameState = _game_state_history.pop_back()
		if not last_state.equals(current_state):
			restore_game_state(last_state)
			save_game_state()
			return
